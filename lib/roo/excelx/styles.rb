require 'roo/font'
require 'roo/excelx/extractor'

module Roo
  class Excelx::Styles < Excelx::Extractor
    # convert internal excelx attribute to a format
    def style_format(style)
      id = num_fmt_ids[style.to_i]
      num_fmts[id] || Excelx::Format::STANDARD_FORMATS[id.to_i]
    end

    def definitions
      @definitions ||= doc.xpath("//cellXfs").flat_map do |xfs|
        xfs.children.map do |xf|
          fonts[xf['fontId'].to_i]
        end
      end
    end

    private

    def num_fmt_ids
      @num_fmt_ids ||= doc.xpath("//cellXfs").flat_map do |xfs|
        xfs.children.map do |xf|
          xf['numFmtId']
        end
      end
    end

    def num_fmts
      @num_fmts ||= Hash[doc.xpath("//numFmt").map do |num_fmt|
        [num_fmt['numFmtId'], num_fmt['formatCode']]
      end]
    end

    def fonts
     @fonts ||= doc.xpath("//fonts/font").map do |font_el|
        Font.new.tap do |font|
          font.bold = !font_el.xpath('./b').empty?
          font.italic = !font_el.xpath('./i').empty?
          font.underline = !font_el.xpath('./u').empty?
        end
      end
    end
  end
end
