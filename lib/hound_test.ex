Application.start :hound

defmodule HoundTest do
    use Hound.Helpers

    def run do
        Hound.start_session
        set_window_size(current_window_handle(), 5300, 3800)
        navigate_to getBaseUrl()
        wait_until_page_is_loaded()
        # element = find_element(:class, "shop-decoration")
        # move_to(element, 0, 3000)
        # element2 = find_element(:class, "shopee-page-controller")
        # move_to(element2, 0, 5300)
        # File.write("tmp/page_source_6.html", page_source())
        page_source()
        scrollToBottom()
        page_source()
        scrollToBottom()
        # Process.sleep(5000)
        {:ok, document} = Floki.parse_document(page_source())

        #crawl from class "shop-collection-view"
        IO.puts "start collection"
        result_collection = Floki.find(document, "div.shop-collection-view")
        {status, data} = readData(result_collection, "shopee-header-section__content")
        if status === :ok do
            list_item_collection_src = Enum.at(data, 0)
            if list_item_collection_src != nil do
                list_item_collection = Enum.at(Tuple.to_list(list_item_collection_src), 2)
                ShopeeCollection.run(list_item_collection)
            else
                IO.puts "error find div.shop-collection-view"
            end
            # {:ok, data} = JSON.encode(result)
            # IO.puts data
        else
            IO.puts "try again"
        end
        #crawl from class "shop-search-result-view"
        IO.puts "start search-result-view"
        result_search_view = Floki.find(document, "div.shop-search-result-view")
        item_search_view_group_src = Enum.at(result_search_view, 0)
        if item_search_view_group_src != nil do
            item_search_view_group = ReadHtml.extractHtml(Tuple.to_list(item_search_view_group_src))
            list_item_search = Enum.at(item_search_view_group, 2)
            ShopeeSearchView.run(list_item_search)
        else
            IO.puts "error find div.shop-search-result-view"
        end
        # {:ok, data1} = JSON.encode(result_search_view)
        # IO.puts data1
        #crawl from class "shop-sold-out-items-view"
        IO.puts "start sold-out"
        result_soldout = Floki.find(document, "div.shop-sold-out-items-view")
        {status, data} = readData(result_soldout, "shopee-header-section__content")
        if status === :ok do
            list_item_sold_out = Enum.at(Tuple.to_list(Enum.at(data, 0)), 2)
            ShopeeSoldOut.run(list_item_sold_out)
            # {:ok, data2} = JSON.encode(result_sold_out)
            # IO.puts data2
        else
            IO.puts "try again sold out"
        end
        :ok

        # Automatically invoked if the session owner process crashes
        Hound.end_session
    end

    #input [{}, {}]
    def readData(document, key_break) do
        if(length(document) > 0) do
            [head | tail] = document
            if(is_tuple(head)) do
                #head = {}
                {status, response} = readEachData(head, key_break)
                if(status === :notFound) do
                    readData(tail, key_break)
                else
                    {:ok, response}
                end
            else
                {:notFound, nil}
            end
        else
            {:notFound, nil}
        end
    end

    #data = {}
    def readEachData(data, key_break) do
        list = extractDataTupleToList(data)
        if length(list) > 0 do
            htmlClass = retriveClass(list)
            if(htmlClass === key_break) do
                {:ok, Enum.at(list, 2)}
            else
                #[{}, {}]
                children = Enum.at(list, 2)
                readData(children, key_break)
            end
        else
            {:notFound, nil}
        end
    end

    def extractDataTupleToList(data) do
        Tuple.to_list(data)
    end

    #Retrive class
    def retriveClass(value) do
        list = Tuple.to_list(Enum.at(Enum.at(value, 1), 0))
        Enum.at(list, 1)
    end

    def getBaseUrl do
        "https://shopee.vn/apple_flagship_store"
    end

    def wait_until_page_is_loaded() do
        IO.puts "wait"
        Process.sleep(1000)
        case execute_script("return document.readyState") do
           "loading" ->  wait_until_page_is_loaded()
           _ -> scrollToBottom()
        end
    end

    def scrollToBottom do
        execute_script("window.scrollTo(0,document.body.scrollHeight)")
    end
end
