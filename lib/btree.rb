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
    attr_reader :n
    def initialize(options = {})
      @n = options[:n] || 5
    end
  end

  class Node
    attr_reader :items, :parent

    def initialize(parent = 0, values = nil)
      @parent = parent
      @items = if values then values.sort else [] end
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
