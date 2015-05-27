#!/usr/bin/ruby

require 'rubytree'

#monkey path for debugging purposes
module Tree
	class TreeNode
		def print_tree_with_node_content(level = 0, max_depth = nil, block = lambda { |node, prefix|  puts "#{prefix} #{node.name} #{node.content} " })
			prefix = ''

			if is_root?
				prefix << '*'
			else
				prefix << '|' unless parent.is_last_sibling?
				prefix << (' ' * (level - 1) * 4)
				prefix << (is_last_sibling? ? '+' : '|')
				prefix << '---'
				prefix << (has_children? ? '+' : '>')
			end

			block.call(self, prefix)

			return unless max_depth.nil? || level < max_depth # Exit if the max level is defined, and reached.

			children { |child| child.print_tree_with_node_content(level + 1, max_depth, block) if child } # Child might be 'nil'
		end
	end
end

class QueryPlan
	
	attr_accessor :tasks,:opt_trees,:stage_graph
	
	def initialize(json_plan)
	  @stage_list = json_plan["stageList"]
	  @adjacency_list = json_plan["stageGraph"]["adjacencyList"]
	  #@task = json_plan["stageList"][1]["taskList"][0]
	  #@tasks = []
	  @opt_trees = []
	  @stage_list.each do |stage|
		  stage["taskList"].each do |task|
			  @opt_trees << build_opt_graph(task)
			end
		end
		@stage_graph = build_stage_graph(@stage_list, @adjacency_list)
  end
	
  
  def build_tree(root,hash,mapping)	
		root_node = Tree::TreeNode.new(root,mapping[root])
		recursive_build_tree(root_node,root,hash,mapping)
		return root_node 
  end
  
  def build_stage_graph(stage_list,adjacency_list)
    #adjacency = str["stageGraph"]["adjacencyList"]
    adjacency = adjacency_list
    adjacency_hash = {}
    all_node = []
    all_children  = []
    stage_mapping = {}


    adjacency.each do |i|
      all_node << i["node"]
      i["children"].map { |i| all_children << i }
    end

    #str["stageList"]
    stage_list.map { |i| stage_mapping.store(i["stageId"],i["stageType"]) }

    adjacency.each do |i|
      adjacency_hash.store i["node"],i["children"]
    end
    first_stage_id = (all_node - all_children).first
    stage_tree = build_tree(first_stage_id,adjacency_hash,stage_mapping)
   end
  
  def build_opt_graph(task)
    #opt_adjacency = str["stageList"][1]["taskList"][0]["operatorGraph"]["adjacencyList"]
    if task["operatorGraph"] == 'null'
      return Tree::TreeNode.new("null","null")
    end
    opt_adjacency = task["operatorGraph"]["adjacencyList"]
    opt_list = task["operatorList"]
    opt_adjacency_hash = {}
    opt_all_node = []
    opt_all_children = []
    opt_adjacency.each do |i|
      opt_all_node << i["node"]
      i["children"].map { |i| opt_all_children << i } unless i["children"] == "null"
    end
    first_operator_id = (opt_all_node - opt_all_children).first
    opt_adjacency.each do |i|
      if i["children"].class == String
        opt_adjacency_hash.store i["node"],[i["children"]]
      else 
        opt_adjacency_hash.store i["node"],i["children"]
      end 
    end
    opt_mapping = {} 
    opt_list.map { |i| opt_mapping.store(i["operatorId"],i["operatorType"]) }
    operator_tree = build_tree(first_operator_id,opt_adjacency_hash,opt_mapping)
  end
  
  def build_stage_taks_mapping(stage_list)
	  stage_task_hash = {}
	  
	  #str["stageList"]
	  stage_list.each do |stage|
	  	  stage_id = stage["stageId"]
	  	  stage["taskList"].each do |task|
	  		  task_id = task["taskId"]
	  		  if stage_task_hash.keys.include?(stage_id)
	  			  stage_task_hash[stage_id] << task_id
	  		  else
	  			  stage_task_hash.store stage_id,[task_id]
	  		  end
	  	  end
	  end
	  return stage_task_hash
	end
  
  private
  def recursive_build_tree(current_node,t,hash,mapping)    
  		if !hash[t].nil?
  			hash[t].each do |child|
  				current_node << Tree::TreeNode.new(child,mapping[child])
  				recursive_build_tree(current_node[child],child,hash,mapping)
  			end
  		end
  end
  
end


