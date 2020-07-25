defmodule Credo.Check.Params do
  @moduledoc """
  This module provides functions for handling parameters ("params") given to
  checks through `.credo.exs` (i.e. the `Credo.ConfigFile`).
  """

  @doc """
  Returns the given `field`'s `params` value.

  Example:

      defmodule SamepleCheck do
        def param_defaults do
          [foo: "bar"]
        end
      end

      iex> Credo.Check.Params.get([], :foo, SamepleCheck)
      "bar"
      iex> Credo.Check.Params.get([foo: "baz"], :foo, SamepleCheck)
      "baz"
  """
  def get(params, field, check_mod)

  # this one is deprecated
  def get(params, field, keywords) when is_list(keywords) do
    case params[field] do
      nil ->
        keywords[field]

      val ->
        val
    end
  end

  def get(params, field, check_mod) do
    case params[field] do
      nil ->
        check_mod.param_defaults[field]

      val ->
        val
    end
  end

  @doc false
  def builtin_param_names do
    [
      :category,
      :__category__,
      :exit_status,
      :__exit_status__,
      :priority,
      :__priority__,
      :tags,
      :__tags__
    ]
  end

  @doc false
  def category(params, check_mod) do
    params[:__category__] || params[:category] || check_mod.category
  end

  @doc false
  def exit_status(params, check_mod) do
    params[:__exit_status__] || params[:exit_status] || check_mod.exit_status
  end

  @doc false
  def priority(params, check_mod) do
    params[:__priority__] || params[:priority] || check_mod.base_priority
  end

  @doc false
  def tags(params, check_mod) do
    params[:__tags__] || params[:tags] || check_mod.tags
  end
end
