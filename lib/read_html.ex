defmodule ReadHtml do
    # input = []
    def extractHtml(input, index \\ 0) do
      # get list childrens
      childrens = Enum.at(input, 2)
      # value is a tuple
      # get one of childrens by index
      tuple_value = Enum.at(childrens, index)
      # convert to list
      if is_tuple(tuple_value) do
          Tuple.to_list(tuple_value)
      else
          tuple_value
      end
    end

    def retrive(input, indexResult \\ 0, indexChild \\ 2) do
      childrens = Enum.at(input, indexChild)
      # value is a tuple
      Enum.at(childrens, indexResult)
    end
end
