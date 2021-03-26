# frozen_string_literal: true

module Danger
  # Check readme files with any extesion inside main README.md.
  # Results are passed out as a string with warning.
  #
  # @example Running linter
  #
  #          # Runs a linter
  #          readme_docs.lint
  #
  # @see  https://github.com/mikhailushka
  # @tags monday, weekends, time, rattata
  #
  class DangerReadmeDocs < Plugin
    # Lints the globbed readme files. Will fail if changed file was not added in main README.md.
    # Generates a `string` with warning.
    #
    # @param   [String] files
    #          A globbed string which should return the files that you want to lint, defaults to nil.
    #          if nil, modified and added files from the diff will be used.
    # @return  [void]
    #
    def lint
      forgotten_files = []

      changed_files.each do |file|
        next unless valid_file?(file)

        file_expand_path = File.path(file)
        forgotten_files << file_expand_path unless main_readme_content.include?(file_expand_path.downcase)
      end

      warn(warning_generator(forgotten_files)) if forgotten_files.any?
    end

    private

    def valid_file?(file)
      File.readable?(file) &&
        File.basename(file, File.extname(file)).downcase == 'readme'
    end

    # memoize file content
    def main_readme_content
      @main_readme_content ||= File.read('README.md').downcase
    end

    def changed_files
      (git.modified_files + git.added_files)
    end

    def warning_generator(files)
      'Please add mentions of sub readme files ' \
      "in main README.md:\n **#{files.join('<br/>')}**"
    end
  end
end
