#== btree_class
#Stanislaw Kolarzowski 2009
#
#Implemention of B-tree
#    * create B-tree
#    * insert values
#    * delete values
#    * searching values
#    * upper iteration
#    * set order(n)

#In computer science, a B-tree is a tree data structure that keeps data sorted
#and allows searches, insertions, and deletions in logarithmic amortized time.
#Unlike self-balancing binary search trees, it is optimized for systems that read
#and write large blocks of data. It is most commonly used in databases and filesystems.
#more: http://en.wikipedia.org/wiki/B-tree

# See README file



  class BTree
    attr_reader :n, :min, :max, :nodes
    def initialize(options = {})
      @n = options[:n] || 5
      @nodes = []
      @max = @n - 1
      @min = @n / 2
      @id_next = 0
    end

    # Add node to a tree. Set id number of node
    def add(node)
      node.id = @id_next
      @id_next += 1
      @nodes << node
    end

    # Add many subtrees to node
    # Parameter is array of subtree ids
    def add_sub_trees(root, nodes = [])
      nodes.each { |node| @nodes[root].add_sub_tree(@nodes[node]) }
    end

    # Searching a value in the B-tree
    # Return true when found a value, or node id where value should be added
    # Example:
    # Node: ID:0 1 [5] 2 [10] 3 SubNode: ID:2 nil [6] nil [9] nil  Value: 7
    # Number 7 is not in tree but it should be in node(2). Return 2
    def find_value(value, node = 0)
      position = @nodes[node].find_subtree(value)
      if position==false
        true
      else
        if @nodes[node].leaf? then node else find_value(value, @nodes[node].sub_trees[position]) end
      end
    end

    def insert_value(value, node = nil, left = nil, right = nil)
      node_id = find_value(value) if node.nil?
      unless node_id==true
        node ||= @nodes[node_id]
        node.add(value)

        if left || right
          node.add_sub_tree(left)
          node.add_sub_tree(right)
        end

        if node.size>@max
          middle = node.keys[node.size/2]
          left_node = Node.new
          right_node = Node.new
          add(left_node)
          add(right_node)

          node.keys.each do |item|
            if item<middle
              left_node.add(item)
              left_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(item)]]) unless node.sub_trees[node.keys.index(item)].nil?
            end
            if item>middle
              right_node.add(item)
              right_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(item)+1]]) unless node.sub_trees[node.keys.index(item)+1].nil?
            end
          end
          left_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(middle)]]) unless node.sub_trees[node.keys.index(middle)].nil?
          right_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(middle)+1]]) unless node.sub_trees[node.keys.index(middle)+1].nil?

          unless node.parent.nil?
            insert_value(middle, @nodes[node.parent], left_node, right_node)
          else
            new_root_node = Node.new
            add(new_root_node)
            new_root_node.add(middle)
            new_root_node.add_sub_tree(left_node)
            new_root_node.add_sub_tree(right_node)
          end
          node.id = -1  #delete
        end
      else
        p "Insert Error: Value is already in tree "
        false
      end
    end

  end

  # Node looks like  st[key]st[key]st[key]st
  # st - id number of subtree connected to node
  # key - value
  # node has id number and parent(id number of its parent)
  class Node
    attr_reader :sub_trees, :keys
    attr_accessor :id, :parent

    def initialize(keys = [])
      @keys = keys.sort
      @parent = nil
      @id = nil
      @sub_trees = Array.new(@keys.size+1)
    end

    def size
      @keys.size
    end
    
    def left
      @keys.first
    end

    def right
      @keys.last
    end
    
    def leaf?
      @sub_trees.nitems == 0
    end

    # Find subtree where you can find a value
    # Return subtree position in nood or false(value is in node)
    # Example:
    # Node: 0 [5] 1 [10] 2  Value: 7
    # Searching number 7 is greater then 5 and less then 10 so it can be in subtree(1). Return 1
    def find_subtree(value)
      if @keys.include?(value)
        false
      else
        i = 0
        while i<@keys.size
          break if value < @keys[i]
          i += 1
        end
        i
      end
    end

    # Add subtree to a node
    # Return subtree position in nood where subtree was added or false(can not add subtree)
    # Example:
    # Node: ID:1 nil [5] nil [10] nil SubNode: ID:2 nil [1] nil [2] nil
    # SubNode can and will be added before value 5. Return 0
    def add_sub_tree(node)
      i = find_subtree(node.right)
      if i!=false && (i==0 || node.left>@keys[i-1])
        @sub_trees[i] = node.id
        node.parent = @id
        i
      else
        p "Error: can not add subtree"
        false
      end
    end

    # Add value to a node
    # Return true or false(value is already in node, adding value destroy some subtree)
    # Example:
    # Node: 0 [5] nil [10] nil Value: 20
    # New node: 0 [5] nil [10] nil [20] nil
    # Example 2:
    # Node: 0 [5] 1 [10] 2 Value: 20
    # New node: 0 [5] 1 [10] nil [20] nil
    # Return false. Subtree 2 is lost
    def add(element)
      unless @keys.include?(element)
        @keys << element
        @keys.sort!
        #Shift right
        sub_trees_old = @sub_trees.map
        ((@keys.index(element))..(@keys.size)).each do |i|
          @sub_trees[i] = if i>@keys.index(element)+1 then sub_trees_old[i-1] else nil end
        end
        
        if @sub_trees.compact == sub_trees_old.compact
          true
        else
          p "Error: Lost subtree"
          false
        end
      else
        false
      end
    end
  end
