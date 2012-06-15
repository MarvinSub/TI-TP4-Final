#Tecnologico de Costa Rica
#Lenguajes de Programacion
#Tarea Programada #4
#Realizado por Erick Monge, Rafael Oliver y Marvin Suarez

require "rubygems"   #libreria para usar programas gems
require "twitter"    #libreria de twitter para realizar conexion con twitter
require "oauth"      #libreria de para llevar a cabo la autentificacion con el usuario
require 'hpricot'    #libreria para machetear un html 
require 'open-uri'   

$lista_grupos = []   #variable global para almacenar objetos

class Datos

   attr_accessor :valor      #para modificar valor

   def initialize(banda,album,valor,url)  #constructor para inicializar 4 atributos
      @banda = banda
      @album = album
      @valor = valor
      @url = url
   end
   def banda          #getter "obtener banda"
      @banda
   end
   def album          #getter "obtener album"
      @album
   end
   def valor          #getter "obtener valor"
      @valor
   end
   def url            #getter "obtener url"
      @url
   end
end


class Autentificacion                      #clase que realiza la autentificacion con Twitter    

  def initialize()
     @token= "yGVDGKXKbqqmmW4Ep0gsA"       #@token y @secret son los valores de la aplicacion TP3-Lenguajes 
     @secret = "CSpM59XCOL2Sw4dRvZHdLLh1d2BUmdXruTyTauwAW4"
  end

  def conection                            #Se hace la autentificacion para realizar la conexion
      consumer=OAuth::Consumer.new(        #Se crea una instancia cliente para OAunth
      @token, 
      @secret,
      {
        :site=>"http://twitter.com",
        :request_token_url=>"https://api.twitter.com/oauth/request_token",
        :access_token_url =>"https://api.twitter.com/oauth/access_token",
        :authorize_url    =>"https://api.twitter.com/oauth/authorize"
      }) 
      request_token = consumer.get_request_token 
      token_cliente = request_token.token   #Se obtiene el token del usuario
      secret_cliente = request_token.secret #Se obtiene el secret del usuario
      token_cliente = request_token.token   #Se obtiene el token del usuario
      secret_cliente = request_token.secret #Se obtiene el secret del usuario
      puts "\n\n"
      puts "Por favor vaya a la siguiente direccion y autorice la aplicacion con el pin que se le dara: \n"
      puts "https://api.twitter.com/oauth/authorize?oauth_token=" + token_cliente #Pagina para autorizar la aplicacion
      puts "Ingrese el pin que aparece en la pagina que se le indico:" 
      pin_autorizacion = gets.chomp         # Guarda el pin que se muestra en la pagina
    
      begin	
        OAuth::RequestToken.new(consumer, token_cliente, secret_cliente) #se autentica al usuario con los datos brindados
           access_token = request_token.get_access_token(:oauth_verifier => pin_autorizacion)
        Twitter.configure do |config|
          config.consumer_key = @token
          config.consumer_secret = @secret
          config.oauth_token = access_token.token
          config.oauth_token_secret = access_token.secret
      end
      $client = Twitter::Client.new
      $client.verify_credentials
      puts "Felicidades usted a sido autenticado"

      rescue Twitter::Unauthorized
         puts "Error: no se pudo realizar la operacion de autentificacion"
      end
   end
end


class ManipularHTML
   def initialize(url)
      @url_grupo=url
   end

   def extrae_datos      
      pagina = Hpricot(open(@url_grupo)) 			#url donde se extraen los grupos
      pagina.search("li[@class='item']").map{|e| 		#encuentra la posicion de los grupos,
      encontrado = Hpricot( e.to_s )                            #indicados segun el url asignado
      banda = encontrado.search("div[@class='itemsubtext']").inner_html   #encuentra nombre del grupo
      album = encontrado.at("a[@href]")['title']		#encuentra nombre del album
      direccion = encontrado.at("a[@href]")['href']		#encuentra url
      grupo = Datos.new(banda, album, "", direccion)		#crea una instancia del grupo encontrado
      $lista_grupos << grupo}					#almacena el grupo encontrado en una lista

      cont=0
      puts "Espere un momento Por Favor..."
      
      #Este ciclo busca si el album de un grupo es gratis o pagado, 
      #La busqueda la realiza navegando por cada url de algun grupo encontrado
      while cont < 10
         elemento = $lista_grupos[cont]
         pagina = Hpricot(open(elemento.url))                   #Se dirije a la url especificada
         pagina.search("h4[@class]").map{|e|                    
         encontrado = Hpricot( e.to_s )
         valor = encontrado.search("a[@id]").inner_html         #Obtiene si el album es gratis o pagado
         elemento = $lista_grupos[cont]
         elemento.valor=valor
         $lista_grupos[cont] = elemento	                        # actualiza la instancia con el nuevo dato
         }
         cont +=1
	 puts " Cargando .. #{cont * 10}%"
      end
   end
end


class BuscartagsGrupos         #Esta clase hace consultas al usuario

   def initialize()
      @palabra=""
   end

   def realizarBusqueda 
      begin 
         print "Ingrese un genero, ciudad o pais que desea buscar \n: "
         print "Por ejemplo: costa rica, heavy metal, california, ... \n\n"
         tag = gets.chomp
         palabra = tag.gsub(" ","-")
         palabra = palabra.gsub("ñ","n")
         iniciarBusqueda=ManipularHTML.new("http://bandcamp.com/tag/" + palabra )
         iniciarBusqueda.extrae_datos
         MostrarResultados.new.mostrar
      rescue Exception => e
         puts "Error: " + e.to_s
         puts "Error: nombre inválido"
      end
   end
   puts "presione una tecla para continuar" 
end


class Menu      #Clase que realiza realiza consultas al usuario para salir del programa o realizar busquedas

  def imprimir_menu
    ex = false
    puts "\n\n"
    puts "Bienvenid@ a TP-IV Tweet"
    puts "¿Que desea realizar?"
    puts "1 - Buscar grupos"
    puts "2 - Salir de la aplicacion"
    puts "Ingrese algun valor"	
    numero = gets.chomp
    case numero
    when "1" then  
      BuscartagsGrupos.new().realizarBusqueda
    when "2" then
      puts "Adios"
      ex = true
    else
      puts "Opcion no valida.."
    end
    imprimir_menu unless ex
  end
end


class MostrarResultados     #Esta clase imprime los resultados en pantalla
   def mostrar
      begin
      cont = 0
      largo = $lista_grupos.length
      print "\n\n El resultado de la busqueda es el siguiente: \n \n \n"
      while cont < 10
         num= cont+1
         elemento=$lista_grupos[cont]
         print " El    grupo  # #{num}   es:  \n Nombre del grupo: #{elemento.banda} \n Nombre del album: #{elemento.album}\n Costo del disco:  #{elemento.valor}. Para mas informacion siga la siguiente direccion: \n #{elemento.url}\n\n"
         cont +=1
      end
      print "Fin de la Busqueda...\n\n"
      publique=Publicar.new.preguntar
      
      
      rescue Exception => e
         puts "Error: " + e.to_s
      end
   end   
end


class Publicar #Esta clase le pregunta al usuario si desea publicar los resultados en twitter
   def preguntar
      print "¿Desea publicar los resultados? \n"
      puts "1 - Si"
      puts "2 - No \n"
      puts "Por favor digite 1 o 2 : \n"
      numero = gets.chomp    
      case numero
      when "1" then  
         print "Publicando..." 
         publicar= Twetear.new.tweet
      when "2" then
         puts "Menu principal"
         $lista_grupos = []
      end 
   end
end


class Twetear   #Clase que publica cada grupo encontrado
  def tweet
     begin
     cont=0
     while cont < 10
        num=cont+1
        elemento=$lista_grupos[cont]
        puts "\n publicando el resultado  # #{num}"
        resultado=  "Nombre del grupo: #{elemento.banda} Album: #{elemento.album}. #{elemento.valor} in #{elemento.url}"
        $client.update(resultado)   # Por cada grupo encontrado, lo publica en twitter
        cont +=1
     end
     "\n Los resultados se publicaron con exito \n"
     $lista_grupos = []
     rescue Exception => e
        puts "Error: "+e.to_s
     end

     puts "Digite una Tecla Para continuar"
     gets
   end
end
      

def iniciarPrograma                 #Funcion para iniciar la autentificacion
   begin
   autentificar=Autentificacion.new()
   autentificar.conection
   pantallaPrincipal = Menu.new()
   pantallaPrincipal.imprimir_menu
   rescue => e
      puts "Error: La operacion de autentificacion fallo!"
   end
end
			
iniciarPrograma	


 		
