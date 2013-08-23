module Foodtaster
  module RSpec
    module Matchers
      class FileMatcher
        def initialize(path)
          @path = path
        end

        def matches?(vm)
          @vm = vm
          @results = {}
          return false unless vm.execute("sudo test -e #{@path}").successful?


          if @content
            @actual_content = vm.execute("sudo cat #{@path}").stdout

            if @content.is_a?(Regexp)
              @results[:content] = !!@actual_content.match(@content)
            else
              @results[:content] = (@actual_content.to_s == @content.to_s)
            end
          end

          if @owner
            @actual_owner = vm.execute("sudo stat #{@path} -c \"%U\"").stdout.chomp

            @results[:owner] = (@actual_owner.to_s == @owner.to_s)
          end

          @results.values.all?
        end

        def with_content(content)
          @content = content

          self
        end

        def with_owner(owner)
          @owner = owner

          self
        end

        def failure_message_for_should
          ["expected that #{@vm.name} should have file '#{@path}'",
            @content && !@results[:content] && "with content #{@content.inspect}, but actual content is:\n#{@actual_content.inspect}\n",
            @owner && !@results[:owner] && "with owner #{@owner}, but actual owner is #{@actual_owner}"].delete_if { |a| !a }.join(" ")
        end

        def failure_message_for_should_not
          "expected that #{@vm.name} should not have file '#{@path}'"
        end

        def description
          ["have file '#{@path}'",
            @content && "with content #{@content.inspect}",
            @owner && "with owner #{@owner}"].delete_if { |a| !a }.join(" ")
        end
      end

      module MatcherMethods
        def have_file(path)
          FileMatcher.new(path)
        end

        alias_method :have_directory, :have_file
      end
    end
  end
end
