require "Utils"

# Cadena para identificar si una noticia es resumida.
RESUMEN="(R)"


# ------------------
# Class: Noticia
# -----------------
class Noticia
  
  # ---------------------------------------
  # Noticia.new(str,str,Fecha,str) -> Noticia
  # ---------------------------------------
  # El primer argumento es el título de la noticia.
  # El segundo argumento es la fuente de la noticia.
  # El tercer argumento es la fecha de la noticia.
  # El cuarto argumento es el cuerpo de la noticia.
  def initialize(titulo,fuente,fecha,cuerpo)
    
    @titulo=titulo
    @fuente=fuente
    @fecha=fecha
    @cuerpo=cuerpo
    
  end
  
  
  
  #--------------------------------------
  # noticia.numero_parrafos -> int
  # --------------------------------------  
  # Devuelve el número de párrafos del cuerpo de la noticia.
  def numero_parrafos
        
    num=0
    @cuerpo.each_line {|line|num += 1}
    return num
    
  end
  
  
 #--------------------------------------
 # noticia.es_resumen? -> true or false
 # --------------------------------------   
 # Indica si una noticia es un resumen, es decir, si su cuerpo solo tiene un párrafo.
  def es_resumen?

    return numero_parrafos==1
        
  end
  
 
  
  # -----------------------------------------------     
  # noticia.entidades_nombradas -> array 
  # -----------------------------------------------  
  # Devuelve un array con las entidades nombradas del título y cuerpo de la noticia sin repeticiones.
  # 
  # Se utiliza la función 'entidades_nombradas' de la clase 'Utils'.   
  def entidades_nombradas
    
    util=Utils.new
    titulo=titulo_limpio # Devuelve el título normalizado sin la cadena de la constante 'RESUMEN' al final.
    cuerpo=cuerpo_limpio # Devuelve el cuerpo sin referencia al principio.
    texto= titulo+"."+cuerpo
    eenn=util.entidades_nombradas(texto)
    return eenn
      
   end
   
   
 # noticia.palabras_clave([int]) -> array 
 # ------------------------------------ 
 # Devuelve un array con un numero máximo, especificado en la constante 'NUM_PALABRAS_CLAVE', de las 
 # 'palabras clave' que más aparecen en la noticia.
 #   
 # El útimo argumento es opcional y es el número máximo de palabras clave a devolver (por defecto es 8).
 #    
 # Se entiende como 'palabras clave' aquellas palabras que se repiten en la noticia.
 # 
 # Para comprobar si una palabra se repite se utiliza la función 'son_palabras_similares?' de la clase 'Utils'.
 # 
 # La función busca palabras repetidas en el título y el cuerpo de la noticia y las guarda en un 'mapa'
 # cuya clave es el número de repeticiones de la palabras. Al mismo tiempo también se almacenan aquellas palabras
 # que no se encuentran repetidas. Finalmente se devuelven aquellas palabras con más repeticiones y en el caso
 # de no alcanzar el número máximo de palabras clave requeridas se suplirán con  palabras que no se 
 # encuentran repetidas en la noticia.                  
  def palabras_clave (num_palabras_clave=8)
     
     util=Utils.new
     map=Hash.new # Aquí se guardarán las palabras clave, la clave del mapa será el número de repeticiones de las palabras.
     titulo=titulo_limpio # Devuelve el título normalizado sin la cadena de la constante 'RESUMEN' al final.
     cuerpo=cuerpo_limpio # Devuelve el cuerpo sin referencia al principio.
     texto= titulo+"."+cuerpo
     palabras=util.palabras_con_significado(texto)
     sin_repeticiones=[] # Aquí se almacenan las palabras que no se repiten en la noticia. 
     while !palabras.empty?
         palabra=palabras.shift
         aux_palabras=[] # Almacena las palabras que quedan por revisar.
         similar=""
         count=0 # Almacena las repeticiones de cada palabra a comparar.
         palabras.each do |elemento|
             if util.son_palabras_similares?(palabra,elemento) then
                 similar = elemento if similar.empty? # Solo se guarda la primera repetición que aparece.
                 count+=1 
              else
                 aux_palabras << elemento     
              end
         end       
         if !similar.empty? then
             if (map.include?(count))
                 map[count]<<similar
             else
                 map[count]=[similar]    
             end  
         else # No se han encontrado repeticiones de la palabra.
             sin_repeticiones<<palabra                  
         end        
         palabras=aux_palabras  
     end # fin del while
     claves=map.keys
     claves.sort! {|a,b| b <=> a} # Se ordenan las claves del mapa de mayor a menor.
     tema=[] # Almacena todas las palabras clave.
     # Se procede a guardar en el array 'tema' las palabres clave contenidas en el mapa,
     # guardándose primero los valores cuya clave sea mayor.
     claves.each {|clave| map[clave].each {|palabra|tema<<palabra}} 
     # Se comprueba que se han obtenido el número de palabras clave adecuado y en caso contrario
     # las restantes se obtienen del array 'sin_repeticiones'.     
     if  tema.length<num_palabras_clave
         while tema.length<num_palabras_clave
            tema<<sin_repeticiones.shift
          end
     end          
     return tema.slice(0,num_palabras_clave)
   
  end
    
  
  # ---------------------------------------------
  # noticia.es_similar?(Noticia) -> true or false
  # ---------------------------------------------
  # Dice si dos noticias son similares según las entidades nombradas que tengan en común.
  #
  # El útimo argumento es opcional y es para indicar un porcentaje mímimo de similitud (por defecto es 26).
  # 
  # Utiliza la función 'son_misma_entidad_nombrada?(args2)' de la clase 'Utils' para comparar las entidades nombradas. 
  #
  # El algoritmo utilizado para determinar si las noticias son similares es el siguiente:
  # (coincidencias propias + coincidencias de la noticia recibida / suma del total de entidades nombradas de las noticias) *100 > porcentaje
  #
  # La función podría afirmar que dos noticias son similares aunque solo tuviesen en común una entidad nombrada.
  #
  def es_similar? (noticia,porcentaje=28)
    util=Utils.new
    en1=entidades_nombradas
    en2=noticia.entidades_nombradas
    count1=0 # Almacena las coincidencias de la propia noticia.
    count2=0 # Almacena las coincidencias de la noticia que recibe como argumento.
    en1.each do |elemento1|
      encontrada_similitud=false 
      en2.each do |elemento2|
        if util.son_misma_entidad_nombrada?(elemento1,elemento2) then
          count1+=1
          if !encontrada_similitud then
            count2+=1
            encontrada_similitud=true 
          end
        end
      end 
    end
    return ((count1+count2).to_f/(en1.length+en2.length).to_f)*100 > porcentaje
  end
  
  
  # --------------------------------------------------------------------------
  # noticia1==noticia2 -> true or false
  # --------------------------------------------------------------------------
  # Dos fechas son iguales si coinciden sus títulos, sus fuentes y sus fechas.
  def == (noticia)
    
    return (titulo_normalizado==noticia.titulo_normalizado) && (@fecha==noticia.fecha) && (@fuente==noticia.fuente)
    
  end
  
  
  # ---------------------------------------------------------------------------
  # noticia1<=>noticia2 -> -1 or 0 or 1
  # ---------------------------------------------------------------------------
  # Devuelve -1 si la fecha de noticia1 es menor que la de noticia2  o en caso de que sean iguales
  # si el título de noticia1 es menor que el título de noticia 2.
  #
  # Devuelve 0 si la fecha y el título de noticia 1 coinciden con noticia2.
  #
  # Devuelve 1 si la fecha de noticia1 es mayor que la de noticia2  o en caso de que sean iguales
  # si el título de noticia1 es mayor que el título de noticia 2.
  def <=> (noticia)
    
    if (@fecha<noticia.fecha) || ((@fecha==noticia.fecha) && (@titulo<noticia.titulo))
      resultado=-1
    elsif (@fecha==noticia.fecha) && (@titulo==noticia.titulo)
      resultado=0
    else
      resultado=1  
    end
    return resultado  
    
  end
  
  
  # --------------------------------- 
  # noticia.cabecera -> str
  # --------------------------------- 
  # Devuelve la cabecera de la noticia con el título normalizado y específicando si se trata de una noticia resumida.
  def cabecera
    
    titulo=titulo_normalizado
    return titulo+"\n"+@fuente+" - "+@fecha.to_s
       
  end
 
  
  # --------------------------------- 
  # noticia.titulo_normalizado -> str
  # --------------------------------- 
  # Devuelve el título normalizado y añade '(R)' en caso de que la noticia sea un resumen. 
  def titulo_normalizado

      util=Utils.new
      titulo=util.normalizar(@titulo)
      titulo=titulo + " "+RESUMEN if es_resumen?
      return titulo
           
  end 
 
  # ---------------------------------------------
  # noticia.comparar_fecha(Fecha) -> -1 or 0 or 1
  # ---------------------------------------------
  # Devuelve 0 si la fecha de la noticia coincide con la fecha que recibe como argumento.
  # Devuelve -1 si la fecha de la noticia es menor a la fecha que recibe como argumento.
  # Devuelve 1 si la fecha de la noticia es mayor a la fecha que recibe como argumento.
  def comparar_fecha (fecha)
  
    if @fecha==fecha then
        resultado=0
    elsif @fecha<fecha then
        resultado=-1
    else
      resultado=1               
    end  
    return resultado
    
  end
  
  
  # ---------------------------------------------
  # noticia.comparar_fuente(str) -> true or false
  # ---------------------------------------------
  # Comprueba si la fuente de la noticia coincide con la que recibe como parámetro.
  #
  # No distingue entre mayúsculas y minúsculas.
  def comparar_fuente (fuente)
  
    return @fuente.downcase==fuente.downcase
    
  end
  
  
  # ---------------------------------------------
  # noticia.comparar_titulo -> true or false
  # ---------------------------------------------
  # Comprueba si el titulo de la noticia coincide con el que recibe como parámetro.
  #
  # No distingue entre mayúsculas y minúsculas.
  def comparar_titulo (titulo)
    
    util=Utils.new
    titulo=util.normalizar(titulo)
    self_titulo=titulo_limpio
    return self_titulo.downcase==titulo.downcase
    
  end
  
  
  def to_s

    titulo=titulo_normalizado
    return titulo+"\n"+@fuente+" - "+@fecha.to_s+"\n"+"\n"+@cuerpo   
     
  end
  
  
  attr_reader :titulo, :fuente , :fecha 
  

  private
    
  
  
 #---------------------------------- 
 # cuerpo_limpio -> str
 # --------------------------------- 
 # Limpia el inicio del cuerpo en caso de ser necesario.
 # 
 # "Madrid. (EFE).- La nadadora catalana..." => "La nadadora catalana..." 
  def cuerpo_limpio
    
    aux_cuerpo=@cuerpo.split(".-")
    if aux_cuerpo.length>1 then
        aux_cuerpo.delete_at(0)
        cuerpo=aux_cuerpo.join(" ")
    else
        cuerpo=aux_cuerpo[0]
    end
    return cuerpo
    
  end    
  
  
#---------------------------------- 
# titulo_limpio -> str
# --------------------------------- 
# Devuelve el titulo normalizado.
# 
# "El Madrid pierde cntr el Barcelona" => "El Madrid pierde contra el Barcelona" 
 def titulo_limpio
   
   util=Utils.new
   titulo=util.normalizar(@titulo)
   return titulo
   
 end    
  
end

