require "test/unit"
require "lib/btree.rb"

class TestBTree < Test::Unit::TestCase


  # Setup tree:
  #             0
  #         [6,12,18]
  #   //    /     \     \\
  #   1     2     3      4
  # [1,2] [7,8] [13,14] [19,20]
  #
  def setup
    @tree = BTree.new
    @tree.add(Node.new([6, 12, 18]))
    @tree.add(Node.new([1, 2]))
    @tree.add(Node.new([7, 8]))
    @tree.add(Node.new([13, 14]))
    @tree.add(Node.new([19, 20]))
    @tree.add_sub_trees(0, [1, 2, 3, 4])
  end
  
  def test_finding_node
    
  end

  def test_finding_leaf
    
  end

  def test_searching
   
  end

  def test_changing_position
   
  end

  def test_insert

  end



end



