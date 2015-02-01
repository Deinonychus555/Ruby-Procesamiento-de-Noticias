require "LCS"



VOCALES_MAYUSCULAS_TILDE=['Ã','Á','É','Í','Ó','Ú']

# Directorio por defecto donde se encuentra el archivo para normalizar cadenas de caracteres y el
# archivo de stopwords.
DIR_RECURSOS="recursos/"


# -----------------
# Class: Utils
# -----------------
# Proporciona funciones varias.
class Utils
  
  def initialize
    
      @stopwords=cargar_stopwords # Este atributo es un array de stopwords.
      @normalization=cargar_normalization # Este atributo es un mapa.
        
  end
  
  
  # --------------------------------------------------
  # utils.es_stopword?(str) => true or false
  # --------------------------------------------------
  # Indica si una cadena de caracteres es o no una 'stopword'.  
  def es_stopword?(palabra)
           
    aux=palabra.downcase  
    return @stopwords.include?(aux)
            
  end 
  
    
  # ----------------------------------------------------  
  # utils.es_entidad_nombrada?(str) => true or false
  # -----------------------------------------------------
  # Indica si una cadena de caracteres es una entidad nombrada. 
  # 
  # utils.es_entidad_nombrada?("Paco") -> true
  # utils.es_entidad_nombrada?("C-3PO") -> true
  # utils.es_entidad_nombrada?("C-3PO") -> true
  # utils.es_entidad_nombrada?("Ante") -> false
  # utils.es_entidad_nombrada?("juan") -> false
  def es_entidad_nombrada?(palabra)
 
      c=palabra.slice(0..0)
      aux=palabra.downcase if c!=nil   
      return !es_stopword?(aux) && (VOCALES_MAYUSCULAS_TILDE.include?(c) ||  ('A'..'Z')===c) 
  
  end  


  # ----------------------------------------------------  
  # utils.son_misma_entidad_nombrada?(str,str) => true or false
  # ----------------------------------------------------- 
  # Indica si dos entidades nombradas son equivalentes.
  # Se consideran la misma entidad nombrada si una está contenida en la otra.
  #
  # utils.son_misma_entidad_nombrada? ("Rafa Nadal" "Nadal") -> true
  # utils.son_misma_entidad_nombrada? ("Juan A. Sanchez" "Juan Sanchez") -> false
  def son_misma_entidad_nombrada?(en1,en2)
          
      return en1.include?(en2) || en2.include?(en1)  
            
  end

  # ------------------------------------- 
  # utils.entidades_nombradas(str)->array
  # -------------------------------------
  # Devuelve un array con las entidades nombradas contenidas en una cadena.
  # 
  # utils.entidades_nombradas("El R2-D2 es de Luke Skywalker. Luke es un Jedi y R2-D2 es un robot") => [R2 D2, Luke Skywalker, Luke, Jedi]
  def entidades_nombradas(str)
      
      entidad_nombrada=""
      conjunto=[]
      aux=str.scan(/\w+\-\w+|\w+|\W/) 
      aux.each do |elemento| 
          if es_entidad_nombrada?(elemento)
            # A continuación se parte la entidad nombrada con cada aparición de un guión, 
            # se convierte a mayúscula la primera letra de cada parte resultante y se
            # unen las partes con un espacio en blanco en vez de con el guión.
            aux2=elemento.split("-")
            aux2.map! {|e|e.capitalize}
            aux2=aux2.join(" ")  
            entidad_nombrada+=" " if !entidad_nombrada.empty?  
            entidad_nombrada+=aux2
          elsif elemento!=" " && !entidad_nombrada.empty?
              conjunto.push(entidad_nombrada)
              entidad_nombrada=""
          end
      end
      conjunto.push(entidad_nombrada) if !entidad_nombrada.empty?
      eenn = conjunto.uniq # Se eliminan las repeticiones
      return eenn
        
     end

  # ------------------------------------------  
  # utils.palabras_con_significado(str)->array
  # ------------------------------------------
  # Devuelve un array con las entidades nombradas y palabras que no sean 'stopwords' de una cadena .
  # 
  # utils.palabras_con_significado("El padre de Luke SkyWalker no es malo, es malísimo, muy malo") => [padre, Luke SkyWalker, malo, malísimo, malo]   
  def palabras_con_significado (str)
          
        entidad_nombrada=""
        conjunto=[]
        aux=str.scan(/\w+\-\w+|\w+|\W/) 
        aux.each do |elemento| 
            if es_entidad_nombrada?(elemento)
              # A continuación se parte la entidad nombrada con cada aparición de un guión 
              # y la primera letra de cada parte resultante se convierte a mayúscula.
              aux2=elemento.split("-")
              aux2.map! {|e|e.capitalize}
              aux2=aux2.join(" ")  
              entidad_nombrada+=" " if !entidad_nombrada.empty?  
              entidad_nombrada+=aux2
            elsif tiene_significado?(elemento)
                if !entidad_nombrada.empty? then
                  conjunto.push(entidad_nombrada)
                  entidad_nombrada=""
                end
                conjunto.push(elemento)
            elsif elemento!=" " && !entidad_nombrada.empty?
                conjunto.push(entidad_nombrada)
                entidad_nombrada=""
            end
        end
        conjunto.push(entidad_nombrada) if !entidad_nombrada.empty?
        #eenn = conjunto.uniq
        return conjunto
            
  end

  # ----------------------------------------------------------
  # son_palabras_similares? (str,str,[int]) -> true or false 
  # --------------------------------------------------------  
  # Comprueba si dos cadenas son similares.
  #
  # El útimo argumento es opcional y es para indicar un porcentaje mímimo de similitud (por defecto es 70).
  # 
  # Si ambas cadenas son entidades nombradas se utiliza la función 'son_misma_entidad_nombrada?' para compararlas.
  # Si ninguna cadena es una entidad nombrada se utiliza la función 'similar' de la clase 'LCS' para compararlas. 
  # Si una cadena es una entidad nombrada y la otra no se devuelve false.
  
  def son_palabras_similares? (palabra1,palabra2,porcentaje=70)
    
    lcs=LCS.new
    son_similares=false
    if es_entidad_nombrada?(palabra1)&& es_entidad_nombrada?(palabra2) then
        son_similares=true if son_misma_entidad_nombrada?(palabra1,palabra2)
    elsif !es_entidad_nombrada?(palabra1)&& !es_entidad_nombrada?(palabra2) then  
        son_similares=true if lcs.similars(palabra1,palabra2,porcentaje)
    end 
    return son_similares  
     
  end                  
 
         

# ------------------------------
# utils.normalizar (str) -> str
# ------------------------------
# Dada una cadena se normaliza
#
# utils.normalizar("u pájaro no es lbre n una jaula") -> "un pájaro no es libre en una jaula"
def normalizar (texto)
  aux=texto.scan(/\w+\-\w+|\w+|\W/)
  aux.map! {|elemento|corregir(elemento)}  
  aux=aux.to_s
  return aux
end





private

  # --------------------------------------------------
  # utils.tiene_significado?(str) => true or false
  # --------------------------------------------------
  # Indica si una cadena de caracteres posee significado (no es una stopword).  
  # Si la cadena tiene longitud 1 se devuelve false.
  def tiene_significado?(palabra)
         
    aux=palabra.downcase  
    return (aux.length>1) && (!@stopwords.include?(aux)) 
          
  end  

  
  # --------------------
  # corregir(str) -> str
  # --------------------
  # Dada una cadena comprueba si coincide con alguna clave del diccionario '@normalization' y en
  # caso afirmativo se devuelve el valor de dicha clave.
  def corregir (palabra)
      aux=@normalization[palabra] 
      palabra=aux if aux!=nil
      return palabra
  end
  
  
  
  # ------------------------------------
  # cargar_normalization -> Hash
  # ------------------------------------ 
  # Carga un fichero de palabras para normalizar en un mapa, cuyas claves serán palabras abreviadas
  # y su valores las palabras enteras correspondientes.
  def cargar_normalization
          
        normalization=Hash.new
        ruta=DIR_RECURSOS+"normalization.txt"
        if !File.zero?(ruta) then # si el archivo no es vacío
            aux = IO.readlines(ruta)
            aux.each do |elemento|
              par=elemento.split("---")
              par.map! {|elemento|elemento.strip!}
              normalization[par[0]]=par[1]  
            end
        end    
        return normalization 
  end     
    
  
  # ------------------------------------
  # cargar_stopwords -> array
  # ------------------------------------ 
  # Carga un fichero de stopwords.
  def cargar_stopwords
    
     ruta=DIR_RECURSOS+"stopwords.txt"
     if !File.zero?(ruta) then # si el archivo no es vacío
      stopwords = IO.readlines(ruta)
      stopwords.each {|elemento|elemento.strip!} #con la función strip se quitan los saltos de línea y espacios en blanco
     end 
  return stopwords            
    
  end      
   
end
  