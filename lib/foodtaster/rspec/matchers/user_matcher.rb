module Foodtaster
  module RSpec
    module Matchers
      class UserMatcher
        def initialize(username)
          @username = username
        end

        def matches?(vm)
          @vm = vm
          @results = {}

          unless vm.execute("cat /etc/passwd | cut -d: -f1 | grep \"\\<#{@username}\\>\"").successful?
            @results[:user] = false
            return false
          end

          if @group
            @actual_groups = vm.execute("groups #{@username}").stdout.to_s.chomp.split(" ")[2..-1] || []
            @results[:group] = !!@actual_groups.include?(@group)
          end

          @results.values.all?
        end

        def in_group(group)
          @group = group

          self
        end

        def failure_message_for_should
          msg = ["expected that #{@vm.name} should have user '#{@username}'"]

          if @group
            msg << "in group #{@group.inspect}"

            if @results.key?(:group) && !@results[:group]
              msg << " but actual user groups are:\n#{@actual_groups.join(", ")}\n"
            end
          end

          msg.join(" ")
        end

        def failure_message_for_should_not
          "expected that #{@vm.name} should not have user '#{@username}'"
        end

        def description
          ["have user '#{@username}'",
            @group && "in group #{@group}"].delete_if { |a| !a }.join(" ")
        end
      end

      module MatcherMethods
        def have_user(username)
          UserMatcher.new(username)
        end
      end
    end
  end
end
