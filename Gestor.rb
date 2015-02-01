require "Noticia"
require "Hemeroteca"
require "Fecha"
require 'find'

# Directorio por defecto donde se encuentran los archivos de las noticias.
RUTA_NOTICIAS="noticias/"

# Directorio por defecto donde se encuentra el archivo para normalizar el nombre de las fuentes.
RUTA_RECURSOS="recursos/"



# ------------------
# Class: Gestor
# -----------------
# Permite gestionar un grupo de noticias alojadas en un directorio.
class Gestor
  
  
  # ---------------------------------------
  # Gestor.new([dir]) -> Gestor
  # ---------------------------------------
  # Admite un parámetro opcional para indicar el directorio dónde se encuentran las noticias.
  def initialize (ruta_noticias=RUTA_NOTICIAS)
    
    @hemeroteca=Hemeroteca.new
    @fuentes=cargar_normalization_fuentes # Este atributo es un mapa.
    cargar_noticias (ruta_noticias)
    
  end
  
  
  # -----------------------------------------------
  # Muestra las distintas opciones que se pueden realizar con la hemeroteca.
  #
  # "1.-  Listar fuentes."
  # "2.-  Normalizar los títulos de las noticias."
  # "3.-  Mostrar titulares por fuente."
  # "4.-  Mostrar titulares por fuente y fecha."
  # "5.-  Mostrar titulares por numero de parrafos."
  # "6.-  Mostrar noticias determinadas."
  # "7.-  Mostrar listado de noticias ordenadas."
  # "8.-  Mostrar entidades nombradas de una fuente."
  # "9.-  Mostrar noticias similares."
  # "10.- Mostrar estadísticas."
  # "11.- Mostrar palabras clave de cada grupo."
  # "12.- Mostrar titulares por fecha."
  def mostrar_menu

    puts "- - - Cargando noticias - - -"
    puts
    puts "Hemeroteca cargada, #{@hemeroteca.numero_noticias} noticias disponibles."
    puts
    resultado=nil
    while resultado!="S"
        puts "Elija la opción a realizar:"
        puts
        puts "1.-  Listar fuentes."
        puts "2.-  Normalizar los títulos de las noticias."
        puts "3.-  Mostrar titulares por fuente."
        puts "4.-  Mostrar titulares por fuente y fecha."
        puts "5.-  Mostrar titulares por numero de parrafos."
        puts "6.-  Mostrar noticias determinadas."
        puts "7.-  Mostrar listado de noticias ordenadas."
        puts "8.-  Mostrar entidades nombradas de una fuente."
        puts "9.-  Mostrar noticias similares."
        puts "10.- Mostrar estadísticas."
        puts "11.- Mostrar palabras clave de cada grupo."
        puts "12.- Mostrar titulares por fecha."
        puts "13.- Salir."
        opcion=gets.chomp
        puts
        resultado = case
          when opcion == "1" then mostrar_fuentes_disponibles
          when opcion == "2" then mostrar_titulares_normalizados
          when opcion == "3" then mostrar_noticias_por_fuente
          when opcion == "4" then mostrar_noticias_por_fuente_fecha
          when opcion == "5" then mostrar_noticias_por_numero_parrafos
          when opcion == "6" then mostrar_noticias_determinadas
          when opcion == "7" then mostrar_noticias
          when opcion == "8" then mostrar_entidades_nombradas_por_fuente
          when opcion == "9" then mostrar_grupos_noticias_similares
          when opcion == "10" then mostrar_estadisticas  
          when opcion == "11" then mostrar_palabras_clave_grupos
          when opcion == "12" then mostrar_noticias_por_fecha
          when opcion == "13" then break
          else puts "Lo sentimos, ha marcado una opcion no válida."
        end
        puts
        puts "- - - Pulse una tecla para continuar o 's' para salir - - -"
        resultado=gets.chomp.capitalize
    end    
    puts
    puts "Hasta pronto."   
     
  end
  
  
  private
  
  
  # ------------------------------------
  # cargar_normalization_fuentes -> Hash
  # ------------------------------------ 
  # Carga un fichero de fuentes para normalizar en un mapa, cuyas claves serán el nombre de las fuentes abreviadas
  # y su valores el nombre de las fuentes enteras correspondientes.
  def cargar_normalization_fuentes
      
    normalization=Hash.new
    ruta=RUTA_RECURSOS+"fuentes.txt"
    if !File.zero?(ruta) then # Si el archivo no es vacío.
        aux = IO.readlines(ruta)
        aux.each do |elemento|
          par=elemento.split("---")
          par.map! {|elemento|elemento.strip!}
          normalization[par[0]]=par[1]  
        end
    end    
    return normalization 
  end
    
    
  
  # ------------------------------
  # normalizar_fuente (str) -> str
  # ------------------------------
  # Normaliza una fuente para que coincida con las claves del diccionario '@fuentes' de la clase Hemeroteca.
  # Para ello se comprueba que la cadena que  recibe coincide con alguna clave del diccionario '@fuentes'
  # (de la clase Gestor) y en caso afirmativo se devuelve el valor de dicha clave.
  #
  # normalizar_fuente("galicia") -> "La Voz de Galicia"
  # normalizar_fuente("nulo") -> "nulo"          
  def normalizar_fuente (fuente)
      aux_fuente=@fuentes[fuente.downcase] 
      fuente=aux_fuente if aux_fuente!=nil
      return fuente
  end    
  
  
  # ---------------------------------
  # Inserta en la hemeroteca todas las noticias contenidas en la ruta del directorio que recibe.
  def cargar_noticias (ruta_noticias)

    Find.find(ruta_noticias) do |ruta| # Iteramos por todo lo que hay en esa ruta.
        ruta_fichero = case
        # Comprobamos que lo que se encuentra en el directorio es un fichero.
            when File.file?(ruta) then ruta
            when File.directory?(ruta) then nil
            else nil  
        end
      if (ruta_fichero!=nil) && (!File.zero?(ruta_fichero)) then # Si el archivo existe y no es vacío.
         noticia = IO.readlines(ruta_fichero)
         @hemeroteca.insertar!(leer_noticia(noticia))
      end 
    end
  end
  
  
  # ------------------------------
  # procesar_fuente (str) -> str
  # ------------------------------
  # Dada una cadena devuelve una cadena con los tokens alfabéticos unicamente.
  #
  # procesar_fuente("<El Mundo, 10/11/2014>") -> "El Mundo"
  def procesar_fuente (cadena)
            
      fuente=cadena.scan(/[a-záéíóúA-ZÁÉÍÓÚÃ]+/)
      return fuente.join(" ") # con join intercalamos un espacio en blanco entre los tokens
      
  end
      
   
  # ------------------------------
  # procesar_cuerpo (array) -> str
  # ------------------------------
  # Dado un array, que contiene las líneas de una noticia, devuelve una cadena con el cuerpo de la noticia.     
  def procesar_cuerpo (noticia)
            
      cuerpo=""
      i = 2 # Posición del array donde se encuentra el primer párrafo del cuerpo de la noticia.  
      while i < noticia.length 
          cuerpo+=noticia[i] if noticia[i].length>1 # Para ignorar posibles lineas que solo tengan un salto de línea.
          i += 1  
      end
      return cuerpo
   end  
   
  
   
  # ------------------------------
  # leer_noticia (array) -> Noticia
  # ------------------------------
  # Dado un array, que contiene las líneas de una noticia, devuelve un objeto de la clase Noticia. 
  def leer_noticia (noticia)
    fecha_aux=Fecha.new
    titulo=noticia[0].strip!
    fuente=procesar_fuente(noticia[1])
    fecha=fecha_aux.procesar_fecha(noticia[1])
    cuerpo=procesar_cuerpo(noticia)
    return Noticia.new(titulo,fuente,fecha,cuerpo)
    
  end
   
  
  def mostrar_fuentes_disponibles
     
     fuentes=@hemeroteca.fuentes_disponibles
     if fuentes.empty? then
         puts "Lo sentimos, no se han encontrado noticias."
         puts
         puts
     else  
         puts fuentes
         puts
         puts
     end  
   end 
   
   
  def mostrar_titulares_normalizados 

    fuentes=@hemeroteca.fuentes_disponibles
    fuentes.each do |fuente|
        puts fuente
        puts "---------------------"
        puts
        noticias=@hemeroteca.noticias_fuente(fuente)
        noticias1=@hemeroteca.obtener_fragmentos(noticias,"titulo")
        noticias2=@hemeroteca.obtener_fragmentos(noticias,"titulo_normalizado")
        noticias.each_index do |i|
            puts noticias1[i]
            puts noticias2[i]
            puts
        end
        puts
        puts              
    end
    if fuentes.empty? then
        puts "Lo sentimos, no se han encontrado noticias." 
        puts
        puts
    end
                  
  end 
  
   
  def mostrar_noticias_por_fuente
 
        puts "Por favor, introduzca la fuente a buscar."
        fuente=gets.chomp
        puts
        noticias=@hemeroteca.noticias_fuente(normalizar_fuente(fuente),"titulo_normalizado")
        if noticias==nil then
            puts "Lo sentimos, no se han encontrado noticias."
        else  
            noticias.each do |noticia|
                puts noticia
                puts
          end
        end     
        
    end
    
    
  def mostrar_noticias_por_fuente_fecha
  
         puts "Por favor, introduzca la fuente a buscar."
         fuente=gets.chomp
         fuente=normalizar_fuente(fuente)
         puts
         puts "Por favor, introduzca una fecha en formato dd/mm/aaaa."
         fecha=gets.chomp
         puts
         if !fecha.empty? then
             fecha_aux=Fecha.new
             fecha=fecha_aux.procesar_fecha(fecha)
         end  
         noticias=@hemeroteca.noticias_fuente_fecha(fuente,fecha,"titulo_normalizado")
         if noticias==nil then
                puts "Lo sentimos, no se han encontrado noticias."
         else  
                noticias.each do |noticia|
                puts noticia
                puts
                end
         end          
               
     end
    
    
    def mostrar_noticias_determinadas
 
        puts "Por favor, introduzca la cadena a buscar."
        cadena=gets.chomp
        puts
        noticias=@hemeroteca.noticias_texto(cadena)
        if noticias==nil then
            puts "Lo sentimos, no se han encontrado noticias."
        else  
            noticias.each do |noticia|
                 puts "------------------------------------------------------------------------------------------"
                 puts noticia
                 puts "------------------------------------------------------------------------------------------"
                 puts
                 puts
            end
        end    
           
    end
 
    
    def mostrar_noticias
 
      noticias=@hemeroteca.noticias_disponibles("cabecera")
      if noticias==nil then
          puts "Lo sentimos, no se han encontrado noticias."
      else  
          noticias.each do |noticia|
              puts noticia
              puts
      end
      end
             
    end
    
    
    def mostrar_entidades_nombradas_por_fuente
 
        puts "Por favor, introduzca el nombre de la fuente."
        fuente=gets.chomp
        puts
        eenn=@hemeroteca.entidades_nombradas_fuente(normalizar_fuente(fuente))
        if eenn==nil then
            puts "Lo sentimos, no se han encontrado noticias."
        else  
            eenn.each do |en|
                puts en.join(", ")
                puts
            end
        end           
    
    end
    
  
    def mostrar_grupos_noticias_similares
 
      puts "Esta operación puede tardar un poco, le rogamos tenga paciencia por favor."
      puts
      puts
      coleccion = @hemeroteca.noticias_similares
      coleccion.each_index do |i|
           puts "Grupo #{i+1}"   
           puts "--------"
           puts
           grupo=@hemeroteca.obtener_fragmentos(coleccion[i],"cabecera") 
           grupo.each do |noticia|
             puts noticia
             puts
             puts
           end
           puts
           puts 
      end 
      if coleccion.empty? then
        puts "Lo sentimos, no se han encontrado noticias." 
        puts
        puts
      end
                           
   end
   
     
  def mostrar_estadisticas
    
    puts "Esta operación puede tardar un poco, le rogamos tenga paciencia por favor."
    puts
    puts
    puts "Número total de noticias: #{@hemeroteca.numero_noticias}"
    puts
    puts "Número de grupos: #{@hemeroteca.numero_grupos_similares}"
    puts
    puts "Media de noticias resumidas por grupo: #{@hemeroteca.numero_medio_noticias_resumidas}"
    puts
    puts "Media de noticias completas por grupo: #{@hemeroteca.numero_medio_noticias_completas}"
    puts
    puts "Numero de grupos con todas las noticias de la misma fecha: #{@hemeroteca.numero_grupos_misma_fecha}"
    puts
    puts "Numero de grupos con noticias de fecha variada: #{@hemeroteca.numero_grupos_fecha_variada}"
    puts
    puts "Numero de grupos con una única noticia: #{@hemeroteca.numero_grupos_unica_noticia}"
    puts    
  end
  
    
  # Muestra las palabras clave de cada grupo de noticias similares.
  def mostrar_palabras_clave_grupos 
   
      puts "Esta operación puede tardar un poco, le rogamos tenga paciencia por favor."
      puts
      puts
      coleccion = @hemeroteca.palabras_clave_grupos 
      coleccion.each_index do |i|
           puts "Grupo #{i+1}:"   
           puts "---------"
           puts coleccion[i].join(", ")
           puts 
           puts 
      end
      if coleccion.empty? then
           puts "Lo sentimos, no se han encontrado noticias." 
           puts
           puts
      end 
                 
   end
     
       
    def mostrar_noticias_por_fecha
 
        puts "Por favor, introduzca una fecha en formato dd/mm/aaaa."
        fecha=gets.chomp
        puts
        noticias=nil
        if !fecha.empty? then
            fecha_aux=Fecha.new
            fecha=fecha_aux.procesar_fecha(fecha)
            noticias=@hemeroteca.noticias_fecha(fecha,"titulo_normalizado")
        end  
        if noticias==nil then
            puts "Lo sentimos, no se han encontrado noticias."
        else  
            noticias.each do |noticia|
                  puts noticia
                  puts
             end
        end  
                   
    end
    
          
  def mostrar_noticias_por_numero_parrafos
  
        puts "Por favor, introduzca un número de párrafos."
        numero_parrafos=gets.chomp
        numero_parrafos=numero_parrafos.to_i
        puts
        puts "Elija la opción que quiera realizar:"
        puts
        puts "1.-  Número de párrafos igual al dado."
        puts "2.-  Número de párrafos menor o igual al dado."
        puts "3.-  Número de párrafos mayor o igual al dado."
        opcion=gets.chomp
        puts
        noticias = case
          when opcion == "2" then @hemeroteca.noticias_por_numero_parrafos(numero_parrafos,"<=","titulo_normalizado")
          when opcion == "3" then @hemeroteca.noticias_por_numero_parrafos(numero_parrafos,">=","titulo_normalizado")
          else  @hemeroteca.noticias_por_numero_parrafos(numero_parrafos,"==","titulo_normalizado")
        end
        if noticias!=nil then
                noticias.each do |noticia|
                    puts noticia
                    puts
                end  
            else
                puts "Lo sentimos, no se han encontrado noticias."       
            end 
      end
   

 
  
end

