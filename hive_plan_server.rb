#!/usr/bin/ruby

require 'sinatra'
require 'json'
require './query_plan.rb'

set :bind,'10.105.51.252'
post '/' do
  h = JSON.parse request.body.read.gsub(/\n/,"")
  f = QueryPlan.new(h)
  f.opt_trees.each do |tree|
    tree.print_tree_with_node_content
  end
  f.stage_graph.print_tree_with_node_content
  return 'ss'
end

