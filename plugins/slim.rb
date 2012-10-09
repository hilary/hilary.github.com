module Jekyll
  require 'slim'
  class SlimConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /slim/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      begin
        engine = Slim::Template.new { content }.render
      rescue StandardError => e
          puts "!!! Slim Error: " + e.message
      end
    end
  end
end
