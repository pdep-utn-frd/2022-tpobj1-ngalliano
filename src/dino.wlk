import wollok.game.*

object juego{
	var velocidad=1000
	
	method velocidad(){
		return velocidad
	}
	
	method configurar(){
		game.cellSize(13)
		game.width(48)
		game.height(32)
		game.title("Dino Game")
		game.addVisual(suelo)
		game.addVisual(cactus)
		game.addVisual(dino)
		game.addVisual(reloj)
		game.addVisual(orbe)
		game.addVisual(pajaro)
			
		keyboard.space().onPressDo{self.jugar()}	
		keyboard.a().onPressDo{
			if (dino.estaVivo()){
				velocidad=600
				cactus.cambio_velocidad()	
			}
			
		}
		keyboard.d().onPressDo{
			if (dino.estaVivo()){
				velocidad=1400
				cactus.cambio_velocidad()	
			}
		}
		keyboard.s().onPressDo{self.jugar2()}
		keyboard.shift().onPressDo{
			if (dino.estaVivo()){
				velocidad=1000
				cactus.cambio_velocidad()	
			}
		}
				
		game.onCollideDo(dino,{ obstaculo => obstaculo.chocar()})
		
	} 
	
	method iniciar(){
		dino.iniciar()
		reloj.iniciar()
		cactus.iniciar()
		pajaro.iniciar()
		orbe.iniciar()
	}
	
	method jugar(){
		if (dino.estaVivo()){
			dino.saltar()
		}	
			
		else {
			game.removeVisual(gameOver)
			self.iniciar()
		}
		
	}
	
	method jugar2(){
		if (dino.estaVivo()){
			dino.agachar()
		}	
			
		else {
			game.removeVisual(gameOver)
		}
	}
	
	method terminar(){
		game.addVisual(gameOver)
		cactus.detener()
		reloj.detener()
		orbe.detener()
		pajaro.detener()
		dino.morir()
	}
	
}

object gameOver {
	method position() = game.center()
	method text() = "GAME OVER"
}

object reloj {
	
	var tiempo = 0
	
	method text() = tiempo.toString()
	method position() = game.at(1, game.height()-4)
	
	method pasarTiempo() {
		tiempo = tiempo +1
	}
	method iniciar(){
		tiempo = 0
		game.onTick(100000/juego.velocidad(),"tiempo",{self.pasarTiempo()})
	}
	method detener(){
		game.removeTickEvent("tiempo")
	}
}

object orbe {
	
	const posicionInicial = game.at(game.width()+384,suelo.position().y())
	var position = posicionInicial
	

	method image() = "orbe.png"
	method position() = position
	
	method cambio_velocidad(){
		self.detener()
		game.onTick(62500/juego.velocidad(),"moverOrbe",{self.mover()})
	}
	
	method iniciar(){
		position = posicionInicial
		game.onTick(62500/juego.velocidad(),"moverOrbe",{self.mover()})
	}
	
	method mover(){
		position = position.left(1)
		if (position.x() == -1)
			position = posicionInicial
	}
	
	method chocar(){
		dino.potenciar(true)
		game.schedule(10000000/juego.velocidad(),{dino.potenciar(false)})		
	}
	
    method detener(){
		game.removeTickEvent("moverOrbe")
	}
	
}
object cactus {
	
	const posicionInicial = game.at(game.width()-1,suelo.position().y())
	var position = posicionInicial
	

	method image() = "cactus.png"
	method position() = position
	
	method cambio_velocidad(){
		self.detener()
		game.onTick(62500/juego.velocidad(),"moverCactus",{self.mover()})
	}
	
	method iniciar(){
		position = posicionInicial
		game.onTick(62500/juego.velocidad(),"moverCactus",{self.mover()})
	}
	
	method mover(){
		position = position.left(1)
		if (position.x() == -1)
			position = posicionInicial
	}
	
	method chocar(){
		juego.terminar()
	}
	
    method detener(){
		game.removeTickEvent("moverCactus")
	}
}

object pajaro{
	const posicionInicial = game.at(game.width()+168,suelo.position().y())
	var position = posicionInicial
	
	method image() = "pajaro.png"
	method position() = position
	
	method cambio_velocidad(){
		self.detener()
		game.onTick(62500/juego.velocidad(),"moverPajaro",{self.mover()})
	}
	
	method iniciar(){
		position = posicionInicial
		game.onTick(62500/juego.velocidad(),"moverPajaro",{self.mover()})
	}
	
	method mover(){
		position = position.left(1)
		if (position.x() == -1)
			position = posicionInicial
	}
	
	method chocar(){
		if (!dino.agachado())
		juego.terminar()
	}
	
    method detener(){
		game.removeTickEvent("moverPajaro")
	}
}

object suelo{
	
	method position() = game.origin().up(4)
	
	method image() = "suelo.png"
}


object dino {
	var vivo = true
	var imagen ="dinoNormal.png"
	var position = game.at(4,suelo.position().y())
	var agachado = false
	var potenciado = false
	
	method potenciado(){
		return potenciado	
	}
	
	method agachado(){
		return agachado
	}
	
	method potenciar(estado){
		potenciado = estado
		if (potenciado && !agachado)
			imagen = "dinoPotenciado.png"
		if (!potenciado && agachado)
			imagen = "dinoNormalAgachado.png"
		if (!potenciado && !agachado)
			imagen = "dinoNormal.png"
		if (potenciado && agachado)
			imagen = "dinoPotenciadoAgachado.png"
	}
	
	method image() = imagen
	method position() = position
	
	method cambio_imagen(flag){
		if(position.y() == suelo.position().y()) {
			if (agachado){
				if (potenciado)
					imagen = "dinoPotenciado.png"
				else if (!potenciado)
					imagen = "dinoNormal.png"
				agachado = false		
			}
			else if (!agachado)
					{
						if(flag){
							if (potenciado)
								imagen ="dinoPotenciadoAgachado.png"
							else if (!potenciado)
								imagen ="dinoNormalAgachado.png"
							agachado = true
						}
					}
		}
	}
	
	method saltar(){
		self.cambio_imagen(false)
		self.subir(potenciado)
		game.schedule(62500/(juego.velocidad()/12),{self.bajar(potenciado)})
		
	}
	
	method agachar(){
		self.cambio_imagen(true)
	}
	
	method cambio_altura(sube,n){
		if(sube){
			game.schedule(62500/juego.velocidad(),{position = position.up(n)})
			game.schedule(2*62500/juego.velocidad(),{position = position.up(n)})
			game.schedule(3*62500/juego.velocidad(),{position = position.up(n)})
			game.schedule(4*62500/juego.velocidad(),{position = position.up(n)})
		}
		else if(!sube){
			game.schedule(62500/juego.velocidad(),{position = position.down(n)})
			game.schedule(2*62500/juego.velocidad(),{position = position.down(n)})
			game.schedule(3*62500/juego.velocidad(),{position = position.down(n)})
			game.schedule(4*62500/juego.velocidad(),{position = position.down(n)})
		}
	}
	
	method subir(potencia){
		if (potencia){
			self.cambio_altura(true,2)
		}
		else if(!potencia){
			self.cambio_altura(true,1)
		}
	}
	
	method bajar(potencia){
		if (potencia){
			self.cambio_altura(false,2)
		}
		else if(!potencia){
			self.cambio_altura(false,1)
		}
	}
	
	method morir(){
		game.say(self,"¡Auch!")
		vivo = false
	}
	method iniciar() {
		vivo = true
	}
	method estaVivo() {
		return vivo
	}
}