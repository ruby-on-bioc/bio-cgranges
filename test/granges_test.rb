# frozen_string_literal: true

require "test_helper"

# 0.........5.........10........15........20........25........30........35........40
# |-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
#                      0-0-0-0-0-0-0-0-0-0
#                                1-1-1-1-1-1-1-1-1-1
#                                                              2-2-2-2-2-2-2-2-2-2
#                      3-3-3-3-3-3-3-3-3-3-3-3-3-3-3
#                                4-4-4-4-4
#            5-5-5-5-5
# |-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|-|
# 0.........5.........10........15........20........25........30........35........40

class CGRangesTest < Test::Unit::TestCase
  def test_version
    assert_true Bio::CGRanges.const_defined?(:VERSION)
  end

  def test_initialize
    cgranges = Bio::CGRanges.new
    assert_instance_of Bio::CGRanges, cgranges
  end

  def test_add
    cgranges = Bio::CGRanges.new
    r = []
    assert_nothing_raised do
      r << cgranges.add("chr1", 10, 20, 0)
      r << cgranges.add("chr2", 15, 25, 1)
    end
    assert_true(r.all? { |x| x.is_a?(Bio::CGRanges) })
  end

  def test_add_indexed_cgranges
    cgranges = Bio::CGRanges.new
    cgranges.index
    assert_raises(Bio::CGRanges::IndexedError) do
      cgranges.add("chr1", 10, 20, 0)
    end
  end

  def test_add_nil
    cgranges = Bio::CGRanges.new
    assert_raises(TypeError) { cgranges.add(nil, 10, 20, 0)      }
    assert_raises(TypeError) { cgranges.add("chr1", nil, 20, 0)  }
    assert_raises(TypeError) { cgranges.add("chr1", 10, nil, 0)  }
    assert_raises(TypeError) { cgranges.add("chr1", 10, 20, nil) }
  end

  def test_index
    cgranges = Bio::CGRanges.new
    r = nil
    assert_nothing_raised do
      cgranges.add("chr1", 10, 20, 0)
      cgranges.add("chr1", 15, 25, 1)
      r = cgranges.index
    end
    assert_instance_of Bio::CGRanges, r
  end

  def test_index_already_indexed
    cgranges = Bio::CGRanges.new
    cgranges.index
    assert_raises(Bio::CGRanges::IndexedError) { cgranges.index }
  end

  def prepare_crange(except: [])
    cgranges = Bio::CGRanges.new
    invs = [["chr1", 10, 20, 0],
            ["chr1", 15, 25, 1],
            ["chr1", 30, 40, 2],
            ["chr1", 10, 25, 3],
            ["chr1", 15, 20, 4],
            ["chr1", 5, 10, 5],
            ["chr2", 10, 20, 6]]
    invs.each do |inv|
      cgranges.add(*inv) unless except.include?(inv[3])
    end
    cgranges
  end

  def test_overlap
    cgranges = prepare_crange.index
    act = cgranges.overlap("chr1", 12, 22)
    exp = [["chr1", 10, 20, 0],
           ["chr1", 10, 25, 3],
           ["chr1", 15, 25, 1],
           ["chr1", 15, 20, 4]]
    assert_equal exp, act
  end

  def test_overlap_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.overlap("chr1", 12, 22)
    end
  end

  def test_overlap_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.overlap(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.overlap("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.overlap("chr1", 12, nil) }
  end

  def test_contain
    cgranges = prepare_crange.index
    act = cgranges.contain("chr1", 12, 22)
    exp = [["chr1", 15, 20, 4]]
    assert_equal exp, act
  end

  def test_contain_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.contain("chr1", 12, 22)
    end
  end

  def test_contain_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.contain(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.contain("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.contain("chr1", 12, nil) }
  end

  def test_count_overlap
    cgranges = prepare_crange.index
    act = cgranges.count_overlap("chr1", 12, 22)
    exp = 4
    assert_equal exp, act
  end

  def test_count_overlap_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.count_overlap("chr1", 12, 22)
    end
  end

  def test_count_overlap_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.count_overlap(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.count_overlap("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.count_overlap("chr1", 12, nil) }
  end

  def test_count_contain
    cgranges = prepare_crange.index
    act = cgranges.count_contain("chr1", 12, 22)
    exp = 1
    assert_equal exp, act
  end

  def test_count_contain_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.count_contain("chr1", 12, 22)
    end
  end

  def test_count_contain_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.count_contain(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.count_contain("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.count_contain("chr1", 12, nil) }
  end

  def test_coverage_overlap1
    cgranges = prepare_crange(except: [1, 3]).index
    act = cgranges.coverage_overlap("chr1", 12, 22)
    exp = [8, 2]
    assert_equal exp, act
  end

  def test_coverage_overlap2
    cgranges = prepare_crange(except: [0, 3]).index
    act = cgranges.coverage_overlap("chr1", 12, 22)
    exp = [7, 2]
    assert_equal exp, act
  end

  def test_coverage_overlap3
    cranges = prepare_crange.index
    act = cranges.coverage_overlap("chr1", 3, 43)
    exp = [30, 6]
    assert_equal exp, act
  end

  def test_coverage_overlap_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.coverage_overlap("chr1", 12, 22)
    end
  end

  def test_coverage_overlap_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.coverage_overlap(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.coverage_overlap("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.coverage_overlap("chr1", 12, nil) }
  end

  def test_coverage_contain1
    cranges = prepare_crange.index
    act = cranges.coverage_contain("chr1", 12, 22)
    exp = [5, 1]
    assert_equal exp, act
  end

  def test_coverage_contain3
    cranges = prepare_crange.index
    act = cranges.coverage_contain("chr1", 3, 43)
    exp = [30, 6]
    assert_equal exp, act
  end

  def test_coverage_contain_without_index
    cgranges = prepare_crange
    assert_raises(Bio::CGRanges::NoIndexError) do
      cgranges.coverage_contain("chr1", 12, 22)
    end
  end

  def test_coverage_contain_nil
    cgranges = prepare_crange.index
    assert_raises(TypeError) { cgranges.coverage_contain(nil, 12, 22)     }
    assert_raises(TypeError) { cgranges.coverage_contain("chr1", nil, 22) }
    assert_raises(TypeError) { cgranges.coverage_contain("chr1", 12, nil) }
  end

  def test_coverage
    cranges = prepare_crange.index
    act = cranges.coverage("chr1", 15, 20)
    exp = [5, 4]
    assert_equal exp, act
    act = cranges.coverage("chr1", 15, 20, mode: :contain)
    exp = [5, 1]
    assert_equal exp, act
    act = cranges.coverage("chr1", 12, 22, mode: :contain)
    exp = [5, 1]
    assert_equal exp, act
  end
end
