defmodule Credo.Check.Refactor.UselessBlockPipeTest do
  use Credo.Test.Case

  @described_check Credo.Check.Refactor.UselessBlockPipe

  test "it should NOT report violation for valid pipes" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> do_something()
        |> do_something_else()
        |> case do
          :this -> :that
          :that -> :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> refute_issues()
  end

  test "it should NOT report violation for valid pipes to if-expr" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> do_something()
        |> do_something_else()
        |> if do
          :that
        else
          :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> refute_issues()
  end

  test "it should report violation for useless single pipes when included" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> case do
          :this -> :that
          :that -> :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check, include: :single)
    |> assert_issue()
  end

  test "it should report violation for useless pipes to case with function" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> do_something()
        |> case do
          :this -> :that
          :that -> :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> assert_issue()
  end

  test "it should report violation for useless pipes to case with function and further pipe" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> do_something()
        |> case do
          :this -> :that
          :that -> :this
        end
        |> to_string()
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> assert_issue()
  end

  test "it should report violation for useless pipes to if-expr with function" do
    """
    defmodule Test do
      def some_function(arg) do
        arg
        |> do_something()
        |> if do
          :that
        else
          :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> assert_issue()
  end

  test "it should report violation for useless pipes starting with a list" do
    """
    defmodule Test do
      def some_function(arg) do
        [arg]
        |> do_something()
        |> case do
          :this -> :that
          :that -> :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> assert_issue()
  end

  test "it should report violation for useless pipes starting with a map" do
    """
    defmodule Test do
      def some_function(arg) do
        %{a: 5}
        |> do_something()
        |> case do
          :this -> :that
          :that -> :this
        end
      end
    end
    """
    |> to_source_file
    |> run_check(@described_check)
    |> assert_issue()
  end
end
