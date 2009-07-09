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
    attr_reader :n
    attr_accessor :nodes
    def initialize(options = {})
      @n = options[:n] || 5
      @nodes = []
    end

    #Return: id for next node
    def id
      @nodes.size
    end

    #insert value

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

  end

  class Node
    attr_reader :id, :items, :parent, :position

    def initialize(id, options = {})
      @parent = options[:parent] || nil
      @position = options[:position] || 0
      @items = options[:values] || []
      @items.sort!
      @id = id
    end

    def size
      @items.size
    end

    def left
      @items.first
    end

    def right
      @items.last
    end

    def add(element)
      unless @items.include?(element)
        @items << element
        @items.sort!
      end
    end

    def delete(element)
      @items.delete(element)
    end

    #Return position where element should be added
    #Return: id or false if element is in node
    def subtree(element)
      if self.items.include?(element)
        false
      else
        i = 0
        while self.items[i]<element
          i += 1
          break if i==self.size
        end
        i
      end
    end
  end
