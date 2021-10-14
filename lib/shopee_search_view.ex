defmodule ShopeeSearchView do

    # list_item_collection = [{}, {}]
    def run(list_item_collection) do
        Enum.reduce(list_item_collection, [], fn x, acc -> [readEachData(x) | acc] end)
    end

    def readEachData(item) do
        # # children = <a>
        childrens = ReadHtml.extractHtml(Tuple.to_list(item))
        |> ReadHtml.extractHtml
        |> ReadHtml.extractHtml
        |> Enum.at(2)


        container_text_price = childrens |> Enum.at(1)
        product_name_tag_html = ReadHtml.extractHtml(Tuple.to_list(container_text_price)) |> ReadHtml.extractHtml
        product_name = ReadHtml.extractHtml(product_name_tag_html) |> ReadHtml.retrive

        product_price_group_tag_html = ReadHtml.extractHtml(Tuple.to_list(container_text_price), 1)
        childrens_price_group = Enum.at(product_price_group_tag_html, 2)
        results = Enum.filter(childrens_price_group, fn x -> checkIsPriceTag(x) end)
        price_group_html = Tuple.to_list(Enum.at(results, 0))
        price_group = retriveProductPrice(price_group_html)

        container_image = childrens |> Enum.at(0)
        image_tag_html = ReadHtml.extractHtml(Tuple.to_list(container_image))
        image_src = ReadHtml.retrive(image_tag_html, 5, 1)
        if(image_src != nil) do
            image_product = Enum.at(Tuple.to_list(image_src), 1)
            %{product_name: String.trim(product_name), price_group: price_group, image_product: image_product}
        else
            # response
            IO.puts "image product miss at product: #{product_name}"
            %{product_name: String.trim(product_name), price_group: price_group, image_product: ""}
        end
    end

    def checkIsPriceTag(item) do
        list = Tuple.to_list(item)
        list_of_class = Enum.at(list, 1)
        first_class = Enum.at(list_of_class, 0) |> Tuple.to_list
        Enum.at(first_class, 1) == classNameOfPrice()
    end

    def classNameOfPrice do
        "pcmall-shopmicrofe_2D4chE pcmall-shopmicrofe_jevInm pcmall-shopmicrofe_oeimbL"
    end

    def retriveProductPrice(value) do
        unit_tag_html = ReadHtml.extractHtml(value)
        unit = ReadHtml.retrive(unit_tag_html)

        price_tag_html = ReadHtml.extractHtml(value, 1)
        price = ReadHtml.retrive(price_tag_html)

        price_from = %{"unit" => unit, "price" => price}

        is_more = ReadHtml.extractHtml(value, 2) != nil
        if(is_more) do
            unit_tag_html_to = ReadHtml.extractHtml(value, 3)
            unit_to = ReadHtml.retrive(unit_tag_html_to)

            price_tag_html_to = ReadHtml.extractHtml(value, 4)
            price_to = ReadHtml.retrive(price_tag_html_to)
            price_to = %{"unit" => unit_to, "price" => price_to}
            %{price_from: price_from, price_to: price_to}
        else
            %{price_from: price_from}
        end
    end

end
