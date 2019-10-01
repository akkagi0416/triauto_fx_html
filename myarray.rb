class Array
  def sum
    reduce(:+)
  end

  def mean
    sum.to_f / size
  end

  def average
    mean
  end

  def var
    m = mean
    reduce(0) { |a,b| a + (b - m) ** 2 } / (size - 1)
  end

  def sd
    Math.sqrt(var)
  end

  def median
    a = self
    (a.size % 2).zero? ? a.sort[a.size/2 - 1, 2].inject(:+) / 2.0 : a.sort[a.size/2] 
  end
end

def r(arr1, arr2)
  mean_arr1 = arr1.mean
  mean_arr2 = arr2.mean

  bunshi = 0
  arr1.each_with_index do |a, i|
    bunshi += (arr1[i] - mean_arr1) * (arr2[i] - mean_arr2) 
  end

  bunshi / (arr1.sd * arr2.sd) / (arr1.size - 1)
end
