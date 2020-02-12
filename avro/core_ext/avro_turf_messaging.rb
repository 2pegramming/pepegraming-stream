require 'avro_turf'

class AvroTurf
  class Messaging
    def decode(data, schema_name: nil, namespace: @namespace, subject: nil, version: nil)
      readers_schema = if subject && version
        fetch_schema(subject, version).last
      elsif schema_name
        @schema_store.find(schema_name, namespace)
      else
        raise ArgumentError.new('Neither schema_name nor subject + version provided to determine the schema.')
      end

      stream = StringIO.new(data)
      decoder = Avro::IO::BinaryDecoder.new(stream)

      # The first byte is MAGIC!!!
      magic_byte = decoder.read(1)

      if magic_byte != MAGIC_BYTE
        raise "Expected data to begin with a magic byte, got `#{magic_byte.inspect}`"
      end

      # The schema id is a 4-byte big-endian integer.
      schema_id = decoder.read(4).unpack("N").first

      writers_schema = @schemas_by_id.fetch(schema_id) do
        schema_json = @registry.fetch(schema_id)
        @schemas_by_id[schema_id] = Avro::Schema.parse(schema_json)
      end

      reader = Avro::IO::DatumReader.new(writers_schema, readers_schema)
      reader.read(decoder)
    rescue Excon::Error::NotFound
      raise SchemaNotFoundError.new("Schema with id: #{schema_id} is not found on registry")
    end
  end
end
