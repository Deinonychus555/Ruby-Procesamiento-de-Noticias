require "Noticia"



# ------------------
# Class: Hemeroteca
# -----------------
# Aloja noticias (objetos de la clase Noticia) y permite realizar búsquedas de noticias según 
# diferentes criterios, devolver características de las noticias, calcular estadísticas...
class Hemeroteca
  
  def initialize ()
    
      @noticias=[]
      @grupos=[] # Array que almacena los grupos de noticias similares.
      @tema_grupos=[] # Array que almacena las palabras clave de cada grupo de noticias similares.
      @fuentes=Hash.new
      @fechas=Hash.new
      @parrafos=Hash.new
      
      
  end
  
  
  # -----------------------------
  # hemeroteca.insertar!(Noticia)
  # -----------------------------   
  # Se añade una noticia.
  def insertar! (noticia)
  
    if !@noticias.include?(noticia) then
        @noticias<<noticia
        add_diccionario(@fuentes, noticia.fuente,noticia)
        add_diccionario(@fechas, noticia.fecha.to_s,noticia)
        add_diccionario(@parrafos, noticia.numero_parrafos,noticia)
    end
    
  end
  
  # ---------------------------------------
  # hemeroteca.fuentes_disponibles -> array
  # ---------------------------------------  
  # Devuelve un array con las fuentes disponibles ordenadas de menor a mayor.
  def fuentes_disponibles
      
      fuentes=@fuentes.keys
      return fuentes.sort
      
  end
    
    
  # ---------------------------------------
  # hemeroteca.fechas_disponibles -> array
  # ---------------------------------------
  # Devuelve un array con las fechas disponibles ordenadas de menor a mayor.
  def fechas_disponibles
    
      fechas=@fechas.keys
      return fechas.sort
       
   end
    
  
  # ---------------------------------------
  # hemeroteca.parrafos_disponibles -> array
  # ---------------------------------------
  # Devuelve un array con los números de párrafos disponibles ordenados de mayor a menor.
  def parrafos_disponibles
    
        parrafos=@parrafos.keys
        return parrafos.sort
         
  end
   
   
  # ------------------------------------------------------
  # hemeroteca.noticias_disponibles([str]) -> array or nil
  # ------------------------------------------------------ 
  # Devuelve un array con todas las noticias ordenadas.
  #
  # Admite un argumento opcional que  puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")   
  def noticias_disponibles (fragmento="noticia")
    
    noticias=@noticias.sort if !@noticias.empty?
    return obtener_fragmentos(noticias,fragmento)
      
  end
     
     
  # -----------------------------------------------------
  # hemeroteca.noticias_texto(str, [str]) -> array or nil
  # -----------------------------------------------------  
  # Devuelve un array de noticias, ordenadas, cuyo título contiene el texto que recibe la función.
  #
  # Admite un argumento opcional que  puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")
  def noticias_texto (texto, fragmento="noticia")
  
      noticias=[]
      @noticias.each do |noticia|
          titulo=noticia.titulo
          if titulo.downcase.include?(texto.downcase) then noticias.push(noticia) end
      end
    return obtener_fragmentos(noticias.sort,fragmento)
          
  end
    
    
  # -------------------------------------------------------
  # hemeroteca.noticias_fuente(str, [str]) -> array or nil
  # ------------------------------------------------------- 
  # Devuelve un array con las noticias ,ordenadas, pertenecientes a la fuente indicada.
  #
  # Admite un argumento opcional que  puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")
  def noticias_fuente (fuente, fragmento="noticia")
    
    noticias=nil 
    noticias=@fuentes[fuente].sort if @fuentes.has_key?(fuente) 
    return obtener_fragmentos(noticias,fragmento)
     
  end 
  
  
  
  # -------------------------------------------------------
  # hemeroteca.noticias_fecha(Fecha, [str]) -> array or nil
  # -------------------------------------------------------  
  # Devuelve un array con las noticias, ordenadas, cuya fecha corresponde a la fecha indicada.
  #
  # Devuelve nil si no hay noticias de la fecha dada.
  #
  # Admite un argumento opcional que  puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")
  def noticias_fecha (fecha, fragmento="noticia")
       
      noticias=nil 
      noticias=@fechas[fecha.to_s].sort if @fechas.has_key?(fecha.to_s)    
      return obtener_fragmentos(noticias,fragmento)
      
  end  
  
  
  # ----------------------------------------------------------------------
  # hemeroteca.noticias_fuente_fecha(fuente, Fecha, [str]) -> array or nil
  # ----------------------------------------------------------------------  
  # Devuelve un array con las noticias, ordenadas, cuya fuente y fecha correspondan a las indicadas.
  #
  # Devuelve nil si no hay noticias de la fuente dada, ni de de la fecha dada, ni noticias cuya fuente y fecha
  # coincidan con las indicadas.
  #
  # Admite un argumento opcional que  puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")
  def noticias_fuente_fecha (fuente, fecha, fragmento="noticia")
  
      noticias_fuente=@fuentes[fuente]
      noticias_fecha=@fechas[fecha.to_s]
      if noticias_fecha==nil || noticias_fuente==nil then
          noticias=nil
      else
          noticias=[]
          # Comprobamos la longitud de las noticias obtenidas según la fuente y la fecha para recorrer
          # aquellas con menor longitud. 
          if noticias_fecha.length < noticias_fuente.length then
                 noticias_fecha.each {|noticia| noticias<<noticia if noticia.comparar_fuente(fuente)}
          else   
                noticias_fuente.each {|noticia| noticias<<noticia if noticia.comparar_fecha(fecha)==0}
          end
      end  
      noticias.sort! if noticias!=nil   
      return obtener_fragmentos(noticias,fragmento)   
            
  end
  
 
  # --------------------------------------------------------------------------
  # hemeroteca.noticias_por_numero_parrafos(int, [str], [str]) -> array or nil
  # --------------------------------------------------------------------------
  # Devuelve un array con las noticias, ordenadas, que contengan el número de párrafos indicado.
  # 
  # Admite dos argumentos opcionales:
  # El primer argumento opcional indica el tipo busqueda a realizar, número de párrafos igual, menor igual o 
  # mayor igual al dado. En caso  de no encontrarse dicho parámetro se realizará una búsqueda de número de
  # párrafos mayor igual al dado.
  # El último argumento opcional puede tomar los siguientes valores: ("titulo","titulo_normalizado","cabecera")
  def noticias_por_numero_parrafos (int, ordenacion=">=", fragmento="noticia")
     
       parrafos=parrafos_disponibles 
       noticias=[]
       resultado=case
        when ordenacion=="==" then 
          @parrafos[int].each {|noticia| noticias<<noticia} if @parrafos.has_key?(int)
          noticias
        when  ordenacion=="<=" then
           parrafos.each {|num_parrafos| @parrafos[num_parrafos].each {|noticia| noticias<<noticia} if num_parrafos<=int}
           noticias  
        else
           parrafos.each {|num_parrafos| @parrafos[num_parrafos].each {|noticia| noticias<<noticia} if num_parrafos>=int}
           noticias
       end
         
   return obtener_fragmentos(resultado,fragmento)
       
  end 
  
  
  
  # ----------------------------------------------------------
  # hemeroteca.entidades_nombradas_fuente(str) -> array or nil
  # ----------------------------------------------------------
  # Devuelve un array con las entidades nombradas de cada noticia que pertenezca a la fuente indicada.  
  def entidades_nombradas_fuente (fuente)
  
    noticias=@fuentes[fuente]
    if noticias!=nil then
        eenn=[]
        noticias.each {|noticia| eenn<<noticia.entidades_nombradas} 
    else
        eenn=nil
    end  
    return eenn  
  end 
      
            
  # ---------------------------------------
  # hemeroteca.noticias_similares -> array
  # --------------------------------------- 
  # Devuelve un array de arrays de noticias agrupadas por similitud.
  # Se basa en la propiedad conmutativa para agupar noticias similares.
  def noticias_similares
     
    if @grupos.empty?
      coleccion=[]
      grupo=[]
      noticias=@noticias.clone
      aux_grupo=[]
      aux_noticias=[]
      # A continuación se procede a la agrupación de noticias similares. La forma a proceder será la siguiente:
      # Cogemos la primera de las noticias y la comparamos con el resto para buscar noticias similares.
      # A medida que encontramos noticias similares las sacamos del conjunto de noticias y las almacenamos.
      # Una vez recorrido todo el conjunto, por cada una de las noticias similares obtenidas, repetimos el proceso,
      # buscando nuevas noticias similares a éstas.
      # Cuando ya no se encuentren más noticias similares se guardan las obtenidas en un array.
      # Finalizada la obtención de un grupo de noticias similares, ee vuelve a sacar la primera noticia 
      # del conjunto restante y se vuelve a repetir el proceso hasta que el conjunto quede vacío.
      while !noticias.empty? do
          aux_grupo<<noticias.shift
          while  !aux_grupo.empty?
              noticia1=aux_grupo.shift
              grupo<<noticia1
              noticias.each do |noticia2|
                  if noticia1.es_similar?(noticia2) then
                      aux_grupo<<noticia2
                  else
                      aux_noticias<<noticia2               
                  end
              end
              noticias=aux_noticias
              aux_noticias=[]
          end 
          coleccion<<grupo.sort 
          grupo=[]
      end
      @grupos=coleccion
    end 
    return @grupos
             
  end        
    
  
  # ----------------------------------
  # hemeroteca.palabras_clave -> array
  # ----------------------------------
  # Devuelve un array con el conjunto de palabras clave de cada grupo de noticias similares.
  # Las palabras clave de cada grupo son las palabras clave de la noticia con mayor número de párrafos   
  def palabras_clave_grupos
    
    if @tema_grupos.empty?
        temas=[] # Almacenará las distintas palabras clave de cada grupo de noticias.
        # Se comprueba si ya se ha hecho la agrupación de noticias por similitud y
        # en caso contrario se realiza.
        noticias_similares if @grupos==nil
        # Se busca la noticia del grupo con mayor número de párrafos, ya que consideraremos a ésta como
        # una noticia representativa del grupo (sus palabras claves serán similares a las del resto de noticias).
        @grupos.each do |grupo|
            indice=0
            np=0 # Se usa para almacenar el máximo número de párrafos.
            grupo.each_index do |i|
                aux_np=grupo[i].numero_parrafos
                if aux_np>np then
                    indice=i
                    np=aux_np
                end
            end
            temas<<grupo[indice].palabras_clave
        end
        @tema_grupos=temas
    end   
    return @tema_grupos
    
  end
  
  
  # ----------------------------------------
  # hemeroteca.numero_noticias -> int
  # ---------------------------------------- 
  # Devuelve el numero de noticias disponibles.   
  def numero_noticias
   
    return @noticias.length
             
  end
  
  
  # ----------------------------------------
  # hemeroteca.numero_grupos_similares -> int
  # ---------------------------------------- 
  # Devuelve el numero de grupos de noticias similares.   
  def numero_grupos_similares
    
      noticias_similares if @grupos.empty?
      return @grupos.length
      
  end
  
 
 # ----------------------------------------
 # hemeroteca.numero_medio_noticias_resumidas -> int
 # ---------------------------------------- 
 # Devuelve el número medio de noticias resumidas por grupo. 
  def numero_medio_noticias_resumidas
    
    noticias_similares if @grupos.empty?
    if !@grupos.empty? then
      noticias_resumidas=0
      @noticias.each {|noticia| noticias_resumidas+=1 if noticia.es_resumen?}
      resultado=noticias_resumidas/@grupos.length 
    else
      resultado=0
    end    
    return resultado   
    
  end
  
  
  # ----------------------------------------
  # hemeroteca.numero_medio_noticias_completas -> int
  # ---------------------------------------- 
  # Devuelve el número medio de noticias completas por grupo. 
  def numero_medio_noticias_completas
        
    noticias_similares if @grupos.empty?
    if !@grupos.empty? then
      noticias_completas=0
      @noticias.each {|noticia| noticias_completas+=1 if !noticia.es_resumen?}
      resultado=noticias_completas/@grupos.length 
    else
      resultado=0  
    end  
    return resultado  
        
   end
   
   
   
  # ----------------------------------------
  # hemeroteca.numero_grupos_unica_noticia -> int
  # ---------------------------------------- 
  # Devuelve el número de grupos que contienen una única noticia.
  def numero_grupos_unica_noticia
     
     noticias_similares if @grupos.empty?
     grupos_unica_noticia=0
     @grupos.each {|noticias| grupos_unica_noticia+=1 if noticias.length==1}
     return grupos_unica_noticia
        
  end  
   
   
  # ----------------------------------------
  # hemeroteca.numero_grupos_misma_fecha -> int
  # ---------------------------------------- 
  # Devuelve el número de grupos cuyas noticias son de la misma fecha.
  def numero_grupos_misma_fecha
         
      noticias_similares if @grupos.empty?
      grupos_misma_fecha=0
      @grupos.each do |noticias| 
        fecha=noticias[0].fecha
        misma_fecha= !noticias.any?{|noticia|!(fecha==noticia.fecha)}
        grupos_misma_fecha+=1 if misma_fecha          
      end
      return grupos_misma_fecha
            
  end  
       
  
  # ---------------------------------------------
  # hemeroteca.numero_grupos_fecha_variada -> int
  # --------------------------------------------- 
  # Devuelve el número de grupos cuyas noticias son de fechas variadas.
  def numero_grupos_fecha_variada
             
      noticias_similares if @grupos.empty?
      grupos_fecha_variada=0
      @grupos.each do |noticias| 
          fecha=noticias[0].fecha
          distinta_fecha= noticias.any?{|noticia|!(fecha==noticia.fecha)}
          grupos_fecha_variada+=1 if distinta_fecha          
      end
      return grupos_fecha_variada
                
  end 
  
  
  
  # ------------------------------------------------------------
  # hemeroteca.obtener_fragmentos (array, str) -> array or nil
  # ------------------------------------------------------------
  # Recibe un array de noticias y devuelve un array con los titulos o las cabeceras de dichas noticias,
  # según se especifique en el segundo argumento.
  #
  # Si solo recibe un argumento o el valor de la variable 'fragmento' no es válido devuelve el array sin modificar.
  def obtener_fragmentos (noticias, fragmento)
        
      resultado=case
          when (noticias==nil) || (noticias==[]) then nil 
          when fragmento=="titulo" then noticias.map {|noticia|noticia=noticia.titulo}
          when fragmento=="titulo_normalizado" then noticias.map {|noticia|noticia=noticia.titulo_normalizado}  
          when fragmento=="cabecera" then noticias.map {|noticia|noticia=noticia.cabecera} 
          else noticias   
      end
      return resultado
        
  end
  
  
  private
  
  
  # --------------------------------------------------------------------
  # Añade un valor a un diccionario determinado, en una clave determinada.
  def add_diccionario(diccionario,clave,valor)
       if (diccionario.include?(clave))
         diccionario[clave]<<valor
       else
         diccionario[clave]=[valor]    
       end   
  end
  
  
 
end

