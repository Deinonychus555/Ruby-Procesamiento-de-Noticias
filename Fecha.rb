require "Time"

# ------------------
# Class: Fecha
# -----------------
class Fecha
  
  
  # ---------------------------------------
  # Fecha.new(int,int,int) -> Fecha
  # ---------------------------------------
  # Si el último argumento (el año) consta solo de dos dígitos se le sumará 1900 en caso de que
  # dicho valor sea mayor ala año actual-2000 y se le sumará 2000 en caso contrario.
  #
  # En caso de que los valores introducidos no representen una fecha válida se devuelve la fecha 0/0/0.
  #
  # Fecha.new(4,12,56) -> Fecha.new(4,12,1956)
  # Fecha.new(4,12,2) -> Fecha.new(4,12,2002)
  # Fecha.new(32,13,2015) -> Fecha.new(0,0,0)
  def initialize (dia=0,mes=0,anyo=0)
  
      if (1..31)===dia && (1..12)===mes then
          @dia=dia
          @mes=mes
          fecha_actual=Time.now
          if (anyo.to_s.length==2) then 
              if  anyo>(fecha_actual.year-2000) then 
                  anyo+=1900
               else anyo+=2000 
              end
          end        
          @anyo=anyo
      else
          @dia=0
          @mes=0
          @anyo=0
      end

   end
   
  # ------------------------------------
  # fecha.procesar_fecha(str) -> Fecha
  # ------------------------------------
  # Dada una cadena que representa una fecha se devuelve un objeto de la clase Fecha.
  # En caso de que la cadena no represente una fecha válida se devuelve la fecha 0-0-0.
  #
  # fecha.procesar_fecha("4-12-14") -> Fecha.new(4,12,2014)
  # fecha.procesar_fecha("fecha: 4-12-14") -> Fecha.new(4,12,2014)
  # fecha.procesar_fecha("fecha: ") -> Fecha.new(0,0,0)
  def procesar_fecha (cadena)
        
      aux=cadena.scan(/\d+/)
      dia=aux[0].to_i
      mes=aux[1].to_i
      anyo=aux[2].to_i
      return Fecha.new(dia,mes,anyo)
        
  end
    
    
  def to_s 
  
      dia=@dia.to_s
      mes=@mes.to_s
      dia="0"+dia if dia.length==1
      mes="0"+mes if mes.length==1 
      anyo=@anyo.to_s
      return dia+"-"+mes+"-"+anyo.to_s  
      
  end

  
  def == (fecha)
  
      return (@dia==fecha.dia) && (@mes==fecha.mes) && (@anyo==fecha.anyo)
    
  end
    
 
 def < (fecha)
    
      return ((@dia<fecha.dia) && (@mes<=fecha.mes) && (@anyo<=fecha.anyo)) || ((@mes<fecha.mes) && (@anyo<=fecha.anyo)) || (@anyo<fecha.anyo)
      
  end
    
    
  def <= (fecha)
      
      return self.<(fecha) || self.==(fecha)
  end
   
   
  def > (fecha)
      
      return ((@dia>fecha.dia) && (@mes>=fecha.mes) && (@anyo>=fecha.anyo)) || ((@mes>fecha.mes) && (@anyo>=fecha.anyo)) || (@anyo>fecha.anyo)
        
  end
      
      
  def >= (fecha)
        
      return self.>(fecha) || self.==(fecha)
      
  end
 
  
  # ---------------------------------------------------------------------------
  # fecha1<=>fecha2 -> -1 or 0 or 1
  # ---------------------------------------------------------------------------
  # Devuelve -1 si fecha1 es menor a fecha2.
  #
  # Devuelve 0 si fecha1 es igual a fecha2.
  #
  # Devuelve 1 si fecha1 es mayor a fecha2. 
  def <=> (fecha)

      if ((@dia<fecha.dia) && (@mes<=fecha.mes) && (@anyo<=fecha.anyo)) || ((@mes<fecha.mes) && (@anyo<=fecha.anyo)) || (@anyo<fecha.anyo)
          resultado=-1
      elsif (@dia==fecha.dia)&& (@mes==fecha.mes) && (@anyo==fecha.anyo)  
          resultado=0
      else
          resultado=1  
      end  
      return resultado
  
  end

  


 attr_reader :dia, :mes, :anyo

end

