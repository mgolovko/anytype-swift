class CodegenDefaultOptionsGenerator
  def self.defaultOptions
    options = {
      command: "None",
      toolPath: File.expand_path("#{__dir__}/../../../Tools/anytype-swift-codegen"),
      templatesDirectoryPath: File.expand_path("#{__dir__}/../../../Templates/Middleware"),
      commentsHeaderFilePath: File.expand_path("#{__dir__}/../../../Templates/Middleware/commands+HeaderComments.pb.swift"),
      serviceFilePath: File.expand_path("#{__dir__}/../../../Dependencies/Middleware/protobuf/protos/service.proto"),
    }
  end

  def self.appended_suffix(suffix, inputFilePath, directoryPath)
    unless inputFilePath.nil?
      unless suffix.nil?
        pathname = Pathname.new(inputFilePath)
        basename = pathname.basename
        components = basename.to_s.split(".")
        the_name = components.first
        the_extname = components.drop(1).join(".")
        result_name = directoryPath + "/" + the_name + suffix + ".#{the_extname}"
        result_name
      end
    end
  end

  def self.generateFilePaths(options)
    command = options[:command]
    unless command.tool_transform.nil?
      our_transform = command.our_transform
      tool_transform = command.tool_transform
      result = {
        transform: tool_transform,
        filePath: options[:filePath],
      }
      keys = [:outputFilePath, :templateFilePath, :commentsHeaderFilePath, :importsFilePath]
      for k in keys
        directoryPath = k == :outputFilePath ? Pathname.new(options[:filePath]).dirname.to_s : options[:templatesDirectoryPath]
        value = self.appended_suffix(command.suffix_for_file(k), options[:filePath], directoryPath)
        unless value.nil?
          result[k] = value
        end
      end
      result
    end
  end

  def self.generate(arguments, options)
    result = defaultOptions.merge options
    result = generateFilePaths(result).merge result
    fixOptions(result)
  end
  
  def self.populate(arguments, options)
    new_options = generate(arguments, options)
    new_options = new_options.merge(options)
    fixOptions(new_options)
  end
end
