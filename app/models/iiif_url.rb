# Represents a IIIFUrl and allows you to manipulate individual parameters.
class IIIFUrl
  # @param [String] url a url with the following pattern {scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}
  def initialize(url)
    # rubocop:disable Metrics/LineLength
    regex = %r{(?<scheme>https?)://(?<server>[^/]+)/(?<prefix>[^/]+)/(?<identifier>[^/]+)/(?<region>[^/]+)/(?<size>[^/]+)/(?<rotation>[^/]+)/(?<quality>[^/]+)\.(?<format>.*)}
    # rubocop:enable Metrics/LineLength
    matchdata = regex.match(url)
    raise ArgumentError, "#{url} is not a valid IIIF url" unless matchdata

    # Copy the matchdata to a Hash
    @parts = matchdata.names.each_with_object({}) { |name, acc| acc[name] = matchdata[name] }
  end

  %w(scheme server prefix identifier region size rotation quality format).each do |name|
    class_eval <<-EORUBY, __FILE__, __LINE__ + 1
      def #{name}
        @parts['#{name}']
      end

      def #{name}=(val)
        @parts['#{name}'] = val
      end
    EORUBY
  end

  def to_s
    # TODO: prefix should be optional
    "#{scheme}://#{server}/#{prefix}/#{identifier}/#{region}/#{size}/#{rotation}/#{quality}.#{format}"
  end
end
