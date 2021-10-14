defmodule ShopeeCollection do

    # list_item_collection = [{}, {}]
    def run(list_item_collection) do
        Enum.reduce(list_item_collection, [], fn x, acc -> [readEachData(x) | acc] end)
    end

    def readEachData(item) do
        # children = <a>
        children = retriveContent(Tuple.to_list(item))
        # div class="pcmall-shopmicrofe_3E_KFb"
        div1 = retriveContent(children)
        # div class="pcmall-shopmicrofe_1NdAnX"
        div2 = retriveContent(div1)
        childrens = Enum.at(div2, 2)


        # overplay_image = ReadHtml.extractHtml(content_image, 2)

        # div class="pcmall-shopmicrofe_1WQCvm"
        content_text = Tuple.to_list(Enum.at(childrens, 1))
        content_text_childrens = Enum.at(content_text, 2)
        # div class="pcmall-shopmicrofe_2-Swua"
        content_text_product_name = Tuple.to_list(Enum.at(content_text_childrens, 0))
        product_name = retriveProductName(content_text_product_name)

        # div class="pcmall-shopmicrofe_2-Swua"
        content_text_price_group = Tuple.to_list(Enum.at(content_text_childrens, 1))
        content_text_price = ReadHtml.extractHtml(content_text_price_group)
        price_group = retriveProductPrice(content_text_price)

        content_image = Tuple.to_list(Enum.at(childrens, 0))
        imageAttributes = ReadHtml.extractHtml(content_image)
        image_src = ReadHtml.retrive(imageAttributes, 5, 1)
        if(image_src != nil) do
            image_product = Enum.at(Tuple.to_list(image_src), 1)
            %{product_name: String.trim(product_name), price_group: price_group, image_product: image_product}
        else
            IO.puts "image product miss at product: #{product_name}"
            %{product_name: String.trim(product_name), price_group: price_group, image_product: ""}
        end

    end

    # data =
    def retriveContent(data) do
        # childrens = [{}]
        childrens = Enum.at(data, 2)
        # return []
        Tuple.to_list(Enum.at(childrens, 0))
    end

    def retriveProductName(content_text_product_name) do
        tmp = ReadHtml.extractHtml(content_text_product_name)
        |> ReadHtml.extractHtml

        Enum.at(Enum.at(tmp, 2), 0)
    end

    def retriveProductPrice(content_text_price) do
        content_unit = ReadHtml.extractHtml(content_text_price)
        unit = ReadHtml.retrive(content_unit)
        content_price = ReadHtml.extractHtml(content_text_price, 1)
        price = ReadHtml.retrive(content_price)
        price_from = %{"unit" => unit, "price" => price}

        is_more = ReadHtml.extractHtml(content_text_price, 2) != nil
        if(is_more) do
            unit_tag_html_to = ReadHtml.extractHtml(content_text_price, 3)
            unit_to = ReadHtml.retrive(unit_tag_html_to)

            price_tag_html_to = ReadHtml.extractHtml(content_text_price, 4)
            price_to = ReadHtml.retrive(price_tag_html_to)
            price_to = %{"unit" => unit_to, "price" => price_to}
            %{price_from: price_from, price_to: price_to}
        else
            %{price_from: price_from}
        end

    end

    def retriveQuantitySold(content_text_quantity_sold) do
        ReadHtml.retrive(content_text_quantity_sold)
    end

    def classNameSoldOut do
        "pcmall-shopmicrofe_xHCQO1"
    end

    def classNameDiscount do
        "pcmall-shopmicrofe_105R2z"
    end

    def classNameTop do
        "pcmall-shopmicrofe_7RhIqt"
    end

    def classNameOverlayImage do
        "pcmall-shopmicrofe_IigP76"
    end
end
