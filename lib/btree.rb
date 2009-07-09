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
    attr_reader :n, :min, :nodes
    def initialize(options = {})
      @n = options[:n] || 5
      @nodes = []
      @max = @n - 1
      @min = @n / 2
      @id = 0
    end

    def add(node)
      node.id = @id
      @id += 1
      @nodes << node
    end

    def add_sub_trees(root, nodes = [])
      nodes.each { |node| @nodes[root].add_sub_tree(@nodes[node]) }
    end

    #Finding a leaf node where value should be added
    #If node is not a leaf, find subtree to check(and check it)
    #Return: id of node
    def find_leaf(element, node = 0)
      if leaf?(node)
        node
      else
        find_leaf(element, find_node(node, @nodes[node].subtree(element)).id)
      end
    end

    #Searching a value in the B-tree
    #Return: True/False
    def find_value(value, node = 0)
      subtree = @nodes[node].subtree(value)
      if subtree==false
        true
      else
        if leaf?(node) then false else find_value(value, find_node(node, subtree).id) end
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
      if i!=false && (node.left>@keys[i-1] || i==0)
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
          p "Errot: Lost subtree"
          false
        end
      else
        false
      end
    end
  end
