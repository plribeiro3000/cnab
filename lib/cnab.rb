require "cnab/version"
require "yaml"

module Cnab
  autoload :Line, 'cnab/line'
  autoload :Lote, 'cnab/lote'
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

      lotes = []
      while(line = f.gets)
        if line[7] == "1"
          lote = {
            header_lote: Line.new(line, definition.header_lote),
            detalhes: []
          }
        elsif line[7] == "3"
          if merge
            lote[:detalhes] << Detalhe.merge(line, f.gets, definition)
          else
            lote[:detalhes] << Detalhe.parse(line, definition)
          end
        elsif line[7] == "5"
          lote[:trailer_lote] = Line.new(line, definition.trailer_lote)
          lotes << Lote.new(lote)
        elsif line[7] == "9"
          trailer_arquivo = Line.new(line, definition.trailer_arquivo)
          break
        end
      end

      Retorno.new({ header_arquivo: header_arquivo,
                    lotes: lotes,
                    trailer_arquivo: trailer_arquivo  })
    end
  end

  def self.root_path
    File.expand_path(File.join(File.dirname(__FILE__), '..'))
  end

  def self.config_path
    File.join(root_path, 'config')
  end
end
