require 'active_record'
module OAI::Provider
  # = OAI::Provider::ActiveRecordWrapper
  # 
  # This class wraps an ActiveRecord model and delegates all of the record
  # selection/retrieval to the AR model.  It accepts options for specifying
  # the update timestamp field, a timeout, and a limit.  The limit option 
  # is used for doing pagination with resumption tokens.  The
  # expiration timeout is ignored, since all necessary information is
  # encoded in the token.
  #
  class ActiveRecordWrapper < Model
    
    attr_reader :model, :timestamp_field
    
    def initialize(model, options={})
      @model = model
      @timestamp_field = options.delete(:timestamp_field) || 'updated_at'
      @limit = options.delete(:limit)
      
      unless options.empty?
        raise ArgumentError.new(
          "Unsupported options [#{options.keys.join(', ')}]"
        )
      end
    end
    
    def earliest
      model.find(:first, 
        :order => "#{timestamp_field} asc").send(timestamp_field)
    end
    
    def latest
      model.find(:first, 
        :order => "#{timestamp_field} desc").send(timestamp_field)
    end
    
    def last_id(conditions)
      model.find(:first, :conditions => conditions,
        :order => "#{timestamp_field} desc").id
    end
    
    # A model class is expected to provide a method Model.sets that
    # returns all the sets the model supports.  See the 
    # activerecord_provider tests for an example.   
    def sets
      model.sets if model.respond_to?(:sets)
    end
    
    def find(selector, options={})
      return next_set(options[:resumption_token]) if options[:resumption_token]
      conditions = sql_conditions(options)
      if :all == selector
        total = model.count(:id, :conditions => conditions)
        if(@limit && total > @limit)
          select_partial(ResumptionToken.new(last_id(conditions), options.merge({:last => 0}), nil, total))
        else
          model.find(:all, :conditions => conditions)
        end
      else
        begin
          model.find(selector, :conditions => conditions)
        rescue ActiveRecord::RecordNotFound
          raise OAI::IdException.new
        end
      end
    end
    
    def deleted?(record)
      if record.respond_to?(:deleted_at)
        return record.deleted_at
      elsif record.respond_to?(:deleted)
        return record.deleted
      end
      false
    end    
    
    protected
    
    # Request the next set in this sequence.
    def next_set(token_string)
      raise OAI::ResumptionTokenException.new unless @limit
    
      token = ResumptionToken.parse(token_string)
      total = model.count(:id, :conditions => token_conditions(token))
    
      select_partial(token)
    end
    
    # select a subset of the result set, and return it with a
    # resumption token to get the next subset
    def select_partial(token)
      records = model.find(:all, 
        :conditions => token_conditions(token),
        :limit => @limit, 
        :order => "#{model.primary_key} asc")
      raise OAI::ResumptionTokenException.new unless records
      offset = records.last.send(model.primary_key.to_sym)
      PartialResult.new(records, token.next(offset))
    end
    
    # build a sql conditions statement from the content
    # of a resumption token.  It is very important not to
    # miss any changes as records may change scope as the
    # harvest is in progress.  To avoid loosing any changes
    # the last 'id' of the previous set is used as the 
    # filter to the next set.
    def token_conditions(token)
      last = token.last
      sql = sql_conditions token.to_conditions_hash
      
      return sql if 0 == last
      # Now add last id constraint
      sql[0] << " AND #{model.primary_key} > ?"
      sql << last
      
      return sql
    end
    
    # build a sql conditions statement from an OAI options hash
    def sql_conditions(opts)
      sql = []
      values = []
      
      if(opts[:set])
        sql << "set = ?"
        values << opts[:set]
      end
      
      if(opts[:from])
        sql << "#{timestamp_field} >= ?"
        values << get_time(opts[:from])
      end
      
      if(opts[:until])
        sql << "#{timestamp_field} <= ?"
        values << get_time(opts[:until])
      end
      
      values.unshift(sql.join(' AND '))
    end
    
    #-- OAI 2.0 hack - UTC fix from record_responce 
    def get_time(time)
      (time.kind_of?(Time) ? time : Time.parse(time)).localtime
    end
    
  end
end

