module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  Mikhail Georgievskiy/danger-readme_docs
  # @tags monday, weekends, time, rattata
  #
  class DangerReadmeDocs < Plugin
    def lint
      forgotten_files = []

      changed_files.each do |file|
        next unless File.readable?(file)
        next unless file.end_with?('.md')

        file_expand_path = File.path(file)
        # unless include because excludes for string available in rails >= 4.0.2
        forgotten_files << file_expand_path unless main_readme_content.include?(file_expand_path)
        
        warn(warning_generator(forgotten_files)) if forgotten_files.any?
      end
    end

    private

    # memoize file content
    def main_readme_content
      @main_readme ||= File.read('README.md')
    end

    def changed_files
      (git.modified_files + git.added_files)
    end

    def warning_generator(files)
      "Please add mentions of sub readme files in main README.md:\n **#{files.join('<br/>')}**"
    end
  end
end
