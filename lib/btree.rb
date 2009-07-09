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


  class Tree
    attr_reader :n, :nodes
    def initialize(options = {})
      @n = options[:n] || 5
      @nodes = []
    end

    protected

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
      if i==@nodes.size then nil else i end
    end

    #Finding a leaf node where value should be added
    #If node is not a leaf, find subtree to check(and check it)
    #Return: id of node
    def find_leaf(element, node = 0)
      if leaf?(node)
        node
      else
        i = 0
        while @nodes[node].items[i]<element
          i += 1
          break if i==@nodes[node].size
        end
        find_leaf(element, find_node(node, i))
      end
    end

  end

  class Node
    attr_reader :id, :items, :parent, :position

    @@size = 0

    def initialize(parent = nil, values = nil, position = 0)
      @parent = parent
      @position = position
      @items = if values then values.sort else [] end
      @id = @@size
      @@size += 1
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
  end
