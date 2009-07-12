=begin rdoc
# == btree_class
# Stanislaw Kolarzowski 2009
#
# Implemention of B-tree
#    * create B-tree
#    * insert values
#    * delete values
#    * searching values
#    * upper iteration
#    * set order(n)

# In computer science, a B-tree is a tree data structure that keeps data sorted
# and allows searches, insertions, and deletions in logarithmic amortized time.
# Unlike self-balancing binary search trees, it is optimized for systems that read
# and write large blocks of data. It is most commonly used in databases and filesystems.
# more: http://en.wikipedia.org/wiki/B-tree

# Example:
# tree = BTree.new(:n => 3)                   => Create new B-tree (3 order)
# tree.add_values( ([1, 2, 3, 4, 5, 6, 7])    => Add values to tree
# tree.insert_value(10)                       => Add 10 to tree
# tree.delete_value(10)                       => Delete 10 from tree
# tree.find_value(1)                          => Return true and node id where '1' is
# tree.find_value(100)                        => Return false and node id where '100' should be added
# tree.first_value                            => Return 1
# tree.next(4)                                => Return 5
# tree.nodes[4]                               => Return node with id = 4
# tree.nodes[4].keys                          => Return keys(array) from node with id = 4
# tree.nodes[4].sub_trees                     => Return sub trees(array) from node with id = 4


# See README file for more
=end


  class BTree
    attr_reader :nodes, :root
    def initialize(options = {})    # options: :n, :node
      @n = options[:n] || 5
      @nodes = []
      @max = @n - 1
      @min = @n / 2
      @id_next = 0
      @root = 0
      node = options[:node] || Node.new
      add(node)
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
    # Return true/false when found a value, and node id where value is or where should be added
    # Example:
    # Node: ID:0 2 [5] 3 [10] 4 SubNode: ID:3 nil [6] nil [9] nil  Value: 7
    # Number 7 is not in tree but it should be in node(3). Return [3, false]
    def find_value(value, node = @root)
      position = @nodes[node].find_subtree(value)
      if position==false
        {:node => node, :find => true}
      else
        if @nodes[node].leaf? || @nodes[node].sub_trees[position].nil? then {:node => node, :find => false} else find_value(value, @nodes[node].sub_trees[position]) end
      end
    end

    # Insert new value into B-tree
    # Return false if value is already in tree
    # insert_value(value) - insert value into tree
    # insert_value(value, node, left, right) - insert value into given node with left and right subtrees
    # it is use only as recursive method
    def insert_value(value, node = nil, left = nil, right = nil)
      find_result = if node.nil? then find_value(value) else {:find => false} end   #find node
      unless find_result[:find]
        node ||= @nodes[find_result[:node]]
        node.add(value)

        if left || right                          #add subtrees
          node.add_sub_tree(left)
          node.add_sub_tree(right)
        end

        if node.size>@max
          middle = node.keys[node.size/2]         #find middle value
          left_node = Node.new
          right_node = Node.new
          add(left_node)
          add(right_node)

          node.keys.each do |item|                #make new subtrees(copy value and value's subtrees)
            if item<middle
              left_node.add(item)
              left_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(item)]]) unless node.sub_trees[node.keys.index(item)].nil?
            end
            if item>middle
              right_node.add(item)
              right_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(item)+1]]) unless node.sub_trees[node.keys.index(item)+1].nil?
            end
          end

          # add middle_value's subtrees to left and right subtrees
          left_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(middle)]]) unless node.sub_trees[node.keys.index(middle)].nil?
          right_node.add_sub_tree(@nodes[node.sub_trees[node.keys.index(middle)+1]]) unless node.sub_trees[node.keys.index(middle)+1].nil?

          # add value to parent node or split if parent is root
          unless node.id==@root
            insert_value(middle, @nodes[node.parent], left_node, right_node)
          else
            new_root_node = Node.new
            add(new_root_node)
            new_root_node.add(middle)
            new_root_node.add_sub_tree(left_node)
            new_root_node.add_sub_tree(right_node)
            @root = new_root_node.id
          end
          node.id = -1                            #delete old node
        end
      else
        false
      end
    end

    # Add many values into tree
    def add_values(values = [])
      values.each { |value| insert_value(value) }
    end

    # Return left or right brother node(node with the same parent)
    # Return false if node does not have brother
    # Example:
    # brother(6, :left) - return left brother of node(6)
    # brother(6, :right) - return right brother of node(6)
    def brother(node, which)
      parent_node = @nodes[node.parent]
      position = parent_node.find_subtree(node.left)
      if which==:left
        if position>0 then @nodes[parent_node.sub_trees[position-1]] else false end
      else
        if position<parent_node.size then @nodes[parent_node.sub_trees[position+1]] else false end
      end
    end

    # Delete value from tree
    # Return false if value is not in tree
    # delete_value(10)    => Delete 10 from tree
    # delete_value(10, 5) => Switch 5 to 10 and delete 10(old one) from tree
    def delete_value(value, switch = nil)
      find_result = find_value(value)
      if find_result[:find]
        node = @nodes[find_result[:node]]

        if switch
          switch_node = @nodes[find_value(switch)[:node]]
          switch_node.switch_value(switch_node.keys.index(switch), value)
        end

        if node.leaf?
          if node.size-1>=@min
            # leaf and enough size
            true
          else
            # leaf but not enough size
            merge(node, value) unless node.id==@root
          end
          node.delete(value)
        else
            # not leaf
            delete_value(succ(value), value)
        end
      else
        false
      end
    end


    # Merge nodes if one has less then minimum keys
    # Parameter "empty"
    #   true  =>  value is now in subtree. delete it from this node
    def merge(node, value, empty = false)
      parent = @nodes[node.parent]
      parent_size = parent.size

      left_brother = brother(node, :left) || []
      right_brother = brother(node, :right) || []
        
      if left_brother.size>right_brother.size
        brother_info = {:brother => left_brother, :position => parent.find_subtree(node.left)-1, :value => left_brother.right}
      else
        brother_info = {:brother => right_brother, :position => parent.find_subtree(node.left), :value => right_brother.left}
      end

      node.delete(node.keys[brother_info[:position]]) if empty

      if brother_info[:brother].size>@min
        # can find brother with enough size
        node.add(parent.keys[brother_info[:position]])
        parent.switch_value(brother_info[:position], brother_info[:value])
        brother_info[:brother].delete(brother_info[:value])
      else
        # can not find brother with enough size
        new_keys = []
        new_keys += node.keys
        new_keys << parent.keys[brother_info[:position]]
        new_keys.delete(value) if value
        new_keys.sort!
        new_keys.each { |key| brother_info[:brother].add(key)}
   
        if parent.size-1<@min && parent.id!=@root
          # parent node is too small, becouse we moved one value into sub tree
          merge(parent, value, true)
        else
          # parend node is big enough
          parent.delete(parent.keys[brother_info[:position]])
        end
        node.id = -1                                      #delete old node
        if parent.id==@root && parent_size-1<@min
          #change root, becouse root node is too small(all values were moved to another node)
          @root = brother_info[:brother].id 
          parent.id=-1
        end
      end

      node.sub_trees.compact.each { |sub_tree| brother_info[:brother].add_sub_tree(@nodes[sub_tree]) }  # move sub trees
    end

    # Return next value in tree or false if value is maximum or not in tree
    def succ(value)
      find_result = find_value(value)
      if find_result[:find]
        node = @nodes[find_result[:node]]
        position = node.keys.index(value)

        if node.sub_trees[position+1].nil?                # Is next value in sub tree ?
          if value==node.right                            # Value is at node end ?
            if node.id==@root
              parent = node
              parent_position = node.keys.index(value)+1
            else
              parent = @nodes[node.parent]
              parent_position = parent.find_subtree(value)
            end
            if parent_position<parent.size then parent.keys[parent_position] else false end
          else
            node.keys[position+1]
          end
        else
          sub_tree = @nodes[node.sub_trees[position+1]]
          loop do
            break if sub_tree.leaf?
           sub_tree = @nodes[sub_tree.sub_trees[0]]
          end
          sub_tree.left
        end
      else
        false
      end
    end
    alias next succ

    # Return a first value(smalles) in a tree or false(tree is empty)
    def first_value
      tree = @nodes[@root]
      loop do
        break if tree.leaf?
        tree = @nodes[tree.sub_trees[0]]
      end
      if tree.size>0 then tree.left else false end
    end

    # Return true if B-tree is valid
    # Checking nodes size and values
    def check_tree
      nodes = @nodes.collect { |node| node if node.id>=0  } #without deleted
      nodes.compact!

      size = nodes.all? do |node|
        node.size>=@min && node.size<=@max
      end

      val = nodes.all? do |node|
        less, greater = [], []
        node.sub_trees.each_with_index do |sub_tree, index|
          less << ( @nodes[sub_tree].right < node.keys[index] if index<node.size && !sub_tree.nil? )
          greater << ( @nodes[sub_tree].left > node.keys[index-1] if index>0 && !sub_tree.nil? )
        end
        less.compact!.delete(false).nil? && greater.compact!.delete(false).nil? #Arrays has only true values ?
      end
      
      size && val
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

    # Set value at position(in keys) to new value
    def switch_value(position, value)
      @keys[position]=value
    end


    # Find subtree where you can find a value
    # Return subtree position in nood or false(value is in node)
    # Example:
    # Node: 10 [5] 11 [10] 12  Value: 7
    # Searching number 7 is greater then 5 and less then 10 so it can be in subtree(1) - node(11). Return 1
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
        ((@keys.index(element)+1)..(@keys.size)).each do |i|
          @sub_trees[i] = if i>@keys.index(element)+1 then sub_trees_old[i-1] else nil end
        end
        
        if @sub_trees.compact == sub_trees_old.compact
          true
        else
          # Lost subtree"
          false
        end
      else
        false
      end
    end


    # Delete value from node
    # Return true or false(value is not in tree)
    def delete(element)
      if @keys.include?(element)       
        #Shift left
        sub_trees_old = @sub_trees.map
        ((@keys.index(element))..(@keys.size)-1).each do |i|
          @sub_trees[i] = sub_trees_old[i+1]
        end
        @sub_trees.pop
        @keys.delete(element)     
        true
      else
        false
      end
    end
  end
