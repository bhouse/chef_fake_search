require "chef_fake_search/version"

# fake search results when testing in chef-solo with vagrant

if Chef::Config[:solo]
  Chef::Recipe.class_eval do
    def partial_search(*args, &block)
      result = node["testing"]["partial_search"].fetch(args.inspect)
      if block_given?
        result.each(&block)
      else
        result
      end
    end

    def search(*args, &block)
      result = node["testing"]["search"].fetch(args.inspect)
      if block_given?
        result.each(&block)
      else
        result
      end
    end
  end

  case Chef::VERSION
  when /^11/
    require "chef/dsl/data_query"
    klass = Chef::DSL::DataQuery
  when /^10/
    require "chef/mixin/language"
    klass = Chef::Mixin::Language
  else
    abort "Chef #{Chef::VERSION} not supported"
  end

  klass.class_eval do
    # mock data bags as follows:
    # node["testing"]["data_bag"]["name"] = [ { "id": "foo", "key": "val", ... }, ... ]

    def data_bag(name)
      node["testing"]["data_bag"][name].map {|item| item['id'] }
    end

    def data_bag_item(name, id)
      node["testing"]["data_bag"][name].select {|item| item['id'] == id}.first
    end
  end
end
