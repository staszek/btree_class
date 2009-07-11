require "test/unit"
require "lib/btree.rb"

#class MyClass
 # public :foo

#end

class TestBTree < Test::Unit::TestCase


  # Setup tree:
  #             0
  #         [6,12,18]
  #   //    /     \     \\
  #   1     2     3      4
  # [1,2] [7,8] [13,14] [19,20]
  #
  # Small tree:
  #          0
  #         [4]
  #    /          \
  #    1          2
  #   [2]       [6,8]
  #  /   \   /   |     \
  #  3   4   5   6     7
  # [1] [3] [5] [7] [9, 10]
  #
  def setup
    # Manual tree bulding - insert nodes(with values)
    @tree = BTree.new(:node => Node.new([6, 12, 18]))
    @tree.add(Node.new([1, 2]))
    @tree.add(Node.new([7, 8]))
    @tree.add(Node.new([13, 14]))
    @tree.add(Node.new([19, 20]))
    @tree.add_sub_trees(0, [1, 2, 3, 4])

    # Fast tree bulding - insert values
    @small_tree = BTree.new(:n => 3)
    @small_tree.add_values( (1..10).to_a)
  end

  def test_searching
    all_nodes = @tree.nodes.all? do |node|
      node.keys.all? { |item| @tree.find_value(item)[:find] }
    end
    assert_equal true, all_nodes
    assert_not_equal true, @tree.find_value(24)[:find]
  end

  def test_brother
    assert_equal false, @tree.brother(@tree.nodes[1], :left)
    assert_equal false, @tree.brother(@tree.nodes[4], :right)
    assert_equal 2, @tree.brother(@tree.nodes[1], :right).id
    assert_equal 3, @tree.brother(@tree.nodes[4], :left).id
  end

  def test_insert
    @tree.insert_value(21)
    @tree.insert_value(22)
    assert_equal [19, 20, 21, 22], @tree.nodes[4].keys
    assert_equal false, @tree.insert_value(20)

    empty_tree = BTree.new
    empty_tree.insert_value(10)
    assert_equal [10], empty_tree.nodes[0].keys
  end

  def test_insert_split
    # normal split
    @small_tree.insert_value(11)
    @small_tree.insert_value(12)
    @small_tree.insert_value(13)
    @small_tree.insert_value(14)

    assert_tree(@small_tree)
    assert_equal [10, 12], @small_tree.nodes[16].keys
    assert_equal [13, 14], @small_tree.nodes[18].keys

    # root split
    @small_tree.insert_value(15)
    assert_tree(@small_tree)
    assert_equal [8], @small_tree.nodes[25].keys
    assert_equal [15], @small_tree.nodes[20].keys
  end

  def test_insert_node_size_wrong
    @small_tree.add(Node.new([50,51,52,52,54]))
    assert_not_tree(@small_tree)
  end


  def test_delete_value_in_tree
    assert_equal false, @small_tree.delete_value(11)
  end

  def test_delete_leaf_enough_size
    @small_tree.delete_value(10)
    assert_equal false, @small_tree.find_value(10)[:find]
    assert_equal [9], @small_tree.nodes[12].keys
  end

  def test_delete_with_brother
    @small_tree.delete_value(7)
    assert_tree(@small_tree)
    assert_equal false, @small_tree.find_value(7)[:find]
    assert_equal [6, 9], @small_tree.nodes[9].keys
    assert_equal [8], @small_tree.nodes[11].keys
    assert_equal [10], @small_tree.nodes[12].keys
  end

  def test_delete_without_brother
    @small_tree.delete_value(5)
    assert_tree(@small_tree)
    assert_equal false, @small_tree.find_value(5)[:find]
    assert_equal [6, 7], @small_tree.nodes[11].keys
    assert_equal [8], @small_tree.nodes[9].keys
    assert_equal [9, 10], @small_tree.nodes[12].keys

    #delete all
    @small_tree.delete_value(6)
    assert_tree(@small_tree)
    @small_tree.delete_value(9)
    assert_tree(@small_tree)
    @small_tree.delete_value(7)
    assert_tree(@small_tree)
    @small_tree.delete_value(1)
    assert_tree(@small_tree)
    @small_tree.delete_value(3)
    @small_tree.delete_value(8)
    @small_tree.delete_value(10)
    @small_tree.delete_value(2)
    @small_tree.delete_value(4)
    assert_not_tree(@small_tree)
    assert_equal [], @small_tree.nodes[@small_tree.root].keys

  end

  def test_delete_not_in_leaf
    @small_tree.delete_value(4)
    assert_tree(@small_tree)
    assert_equal false, @small_tree.find_value(4)[:find]
    assert_equal [5], @small_tree.nodes[10].keys
    assert_equal [6, 7], @small_tree.nodes[11].keys
    assert_equal [9, 10], @small_tree.nodes[12].keys
  end

  def test_succ
    assert_equal 7, @tree.succ(6)
    assert_equal 8, @tree.succ(7)
    assert_equal 12, @tree.succ(8)
    assert_equal 5, @small_tree.succ(4)
    assert_equal false, @tree.succ(20)
    assert_equal false, @tree.succ(40)
  end

  def test_first_value
    assert_equal 1, @tree.first_value
    assert_equal 1, @small_tree.first_value
  end

  def assert_tree(tree)
    if tree.check_tree then assert(true) else assert(false) end
  end

  def assert_not_tree(tree)
    unless tree.check_tree then assert(true) else assert(false) end
  end



end



