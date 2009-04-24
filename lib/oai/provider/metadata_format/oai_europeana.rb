module OAI::Provider::Metadata
  # = OAI::Metadata::Europeana
  # 
  # Simple implementation of the Europeana metadata format.
  class Europeana < Format
    
    def initialize
      @prefix = 'ese'
      @schema = 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd'
      @namespace = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
      @element_namespace = 'ese'
      @fields = {:dc => [:title, :creator, :subject, :description, :publisher,
                  :contributor, :date, :type, :format, :identifier,
                  :source, :language, :relation, :coverage, :rights],
                 :dcterms => :provenance,
                 :ese => [:userTag, :unstored, :object, :language, :provider,
                   :type, :uri, :year, :hasObject, :country]
                  }
    end

    def header_specification
      {
        'xmlns:oai_dc'    =>  'http://www.openarchives.org/OAI/2.0/oai_dc/',
        'xmlns:ese'       =>  'http://europeana.eu/terms/',
        'xmlns:dc'        =>  'http://purl.org/dc/terms/',
        'xmlns:dcterms'   =>  'http://purl.org/dc/terms/',
        'xmlns:europeana' =>  'http://europeana.eu/terms/',
        'xmlns:local'     =>  'http://metadata.cerl.org/oai/namespace/local/',
        'xmlns:xsi'       =>  'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 
          %{http://purl.org/dc/elements/1.1/
            http://dublincore.org/schemas/xmls/qdc/dc.xsd http://purl.org/dc/terms/
            http://dublincore.org/schemas/xmls/qdc/dcterms.xsd}
      }
    end

  end
end
