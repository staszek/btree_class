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

    # Is node a leaf?
    # Return: True/False
    def leaf?(node)
      @nodes.all? { |other_node| other_node.parent!=node }
    end

    #Finding node
    #Return: id of node or nil
    def find_node(parent, position)
      i = 0
      while i<@nodes.size
        break if @nodes[i].parent==parent && @nodes[i].position==position
        i += 1
      end
      if i==@nodes.size then nil else @nodes[i] end
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

    #Move subtrees to make space for new value(and its subtrees)
    def change_position(node, position)
      elements =[]
      (position..(node.size)).each do |item|
        elements << find_node(node.id, item)
      end
      elements.compact!
      elements.each { |element| element.incrase_position } unless elements.empty?
    end

    
    #Insert new value into B-tree
    #Example: insert_value(10) - insert value 10 to tree
    #         insert_value(10, 2, [1,2], [3,4]) - insert value 10 to node 2 and add subtrees to inserted element
    def insert_value(value, node = nil, lnode = nil, rnode = nil)
      node ||= @nodes[find_leaf(value)]
      new_position = node.add(value)

      #Add sub trees
      change_position(node, new_position)
      if lnode || rnode
        add(Node.new(:parent => node.id, :values => lnode, :position => new_position))
        add(Node.new(:parent => node.id, :values => rnode, :position => new_position+1))
      end

      if node.size>@max
        middle = node.items[node.items.size/2]
        left_node = Node
        right_node = []
        node.items.each do |item|
          if item < middle
            left_node << item
          elsif item > middle
            right_node << item
          end
        end
        insert_value(middle, @nodes[node.parent], left_node, right_node) if node.parent
        @nodes.delete(node)
      end
    end

  end

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

    def add_sub_tree(node)
      i = 0
      while i<@keys.size
        break if node.right < @keys[i]
        i += 1
      end
      if node.left>@keys[i-1] || i==0
        @sub_trees[i] = node.id
        node.parent = @id
        i
      else
        p "Error: can not add subtree"
        false
      end
    end

    def add(element)
      unless @keys.include?(element)
        @keys << element
        @keys.sort!
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

    def delete(element)
      @items.delete(element)
    end
  end
