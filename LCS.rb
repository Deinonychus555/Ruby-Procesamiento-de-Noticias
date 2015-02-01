class LCS
  
  def lcs s1, s2
    common_subsequence = String.new

    m = lcsLengthTable s1, s2 
    
    x = 0
    y = 0
    while (x < s1.length && y < s2.length)
      if (s1[x,1] == s2[y,1]) 
         common_subsequence += s1[x,1]
         x = x + 1
         y = y + 1
      elsif (m[x+1][y] >= m[x][y+1])   
         x = x + 1
      else
         y = y + 1                        
      end        
    end   
    
    return common_subsequence
  end  
  
  def lcsr(s1, s2)
        lcs = LCS.new
        lc_sequence = lcs.lcs(s1, s2)
       
        if (s1.length > s2.length)
            return lc_sequence.length.to_f / s1.length
        else
            return lc_sequence.length.to_f / s2.length      
        end
      end  
      
   # Dice si dos cadenas son similares con un determinado porcentaje
   # El tercer parámetro es un número entre 0 y 100
   def similars(s1,s2,percentage)
     s1d = s1.downcase
     s2d = s2.downcase
     
     return self.lcsr(s1d,s2d) > get_threshold(percentage)     
   end  

  private  
   
    def get_threshold(percentage)
       return percentage.to_f / 100
    end
  
    
    
    # @params s1 vetical; s1 horozontal
    # @return lengthTable, height, width
    def lcsLengthTable s1, s2
      height, width = s1.size, s2.size
      
      # 0th col and row are used for index convenience
      t = Array.new(height+1) { Array.new(width+1) { 0 } }
      
      for i in 0..s1.length-1
        for j in 0..s2.length-1
          if s1[i].chr == s2[j].chr
            t[i][j] = t[i-1][j-1] + 1
          elsif t[i-1][j] >= t[i][j-1]
            t[i][j] = t[i-1][j]
          else
            t[i][j] = t[i][j-1]
          end          
        end
      end
        
      t
    end
    
    def max(n1,n2)
      if (n1>=n2)
        return n1
      else
        return n2          
      end        
    end  
    
=begin
    # Pruebas
    s1 = "pollinazione";
    s2 = "pollenation";   
    s = LCS.new
    puts s.lcsr(s1,s2)
    if (s.similars(s1,s2,70))
      puts "Son similares"
    else
      puts "No son similares"      
    end
=end      
end