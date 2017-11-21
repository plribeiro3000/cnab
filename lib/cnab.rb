require "cnab/version"
require "yaml"

module Cnab
  autoload :Line, 'cnab/line'
  autoload :MergedLines, 'cnab/merged_lines'
  autoload :Detalhe, 'cnab/detalhe'
  autoload :Retorno, 'cnab/retorno'
  autoload :Config, 'cnab/config'
  autoload :Configs, 'cnab/configs'
  autoload :PrettyInspect, 'cnab/pretty_inspect'

  autoload :Exceptions, 'cnab/exceptions'

  def self.parse(file = nil, merge = false, version = '08.7')
    raise Exceptions::NoFileGiven if file.nil?
    raise Exceptions::MissingLines if %x{wc -l #{file}}.scan(/[0-9]+/).first.to_i < 5

    definition = Cnab::Configs.new(version)

    File.open(file, 'rb') do |f|
      header_arquivo = Line.new(f.gets, definition.header_arquivo)
      header_lote = Line.new(f.gets, definition.header_lote)

      detalhes = []
      segmento_y_50 = []
      while(line = f.gets)
        if line[7] == "5"
          trailer_lote = Line.new(line, definition.trailer_lote)
          break
        end
        if line[13] == "Y"
          segmento_y_50 << Line.new(line, definition.segmento_y_50)
        elsif merge
          detalhes << Detalhe.merge(line, f.gets, definition)
        else
          detalhes << Detalhe.parse(line, definition)
        end
      end

      trailer_arquivo = Line.new(f.gets, definition.trailer_arquivo)
      Retorno.new({ :header_arquivo => header_arquivo,
                    :header_lote => header_lote,
                    :detalhes => detalhes,
                    :segmento_y_50 => segmento_y_50,
                    :trailer_lote => trailer_lote,
                    :trailer_arquivo => trailer_arquivo  })
    end
  end

  def self.root_path
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def self.config_path
    File.join(root_path, 'config')
  end
end