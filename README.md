
Escribir introduccion y revisar todo lo que se puso abajo, luego pasar todo a markdown


- Mosquitto
 Aqui solo acotar que si queremos exportar la configuracion de mosquitto mientras se descubre porque vacia la carpeta hay que copiar en la carpeta donde se exporte el contenifo de la carpeta config de este proyecto


- Influxdb test
Conectarse al contenedor usando "docker exec -it <nombre contenedor> bash"
llamar al cliente "influx"
en el cliente ejecutar los siquientes comandos
CREATE DATABASE statsdemo
SHOW DATABASES
USE statsdemo
INSERT cpu,host=serverA value=0.64
INSERT cpu,host=serverA value=0.66
SELECT * from cpu
exit

puede tambien desde la maquina host probar ejecutar una llamada como la siguiente
curl -i -XPOST 'http://localhost:8086/write?db=statsdemo' --data-binary 'cpu,host=serverB value=`cat /proc/loadavg | cut -f1 -d" "`'

- Grafana
usuario por defecto admin y clave admin 
Aqui escribir pasos para usar la base de datos anterior



- TODO
    - Sacar la carpeta node_modules para la carpeta que se exporta
    - Organizar todo el Dockerfile
    - Agregar variables de entorno para establecer qeu servicios queremos que se inicien y cuales no
    - lo mismo anterior pero para configurar mejor los servicios
    - agregar la posibilidad de agregarle usuario y clave por defecto a mosquito
    - poder pasar nodos extras al docker composer para que se instalen en el momento de levantar el contenedor