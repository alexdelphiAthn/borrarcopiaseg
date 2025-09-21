BorrarFich nace como una necesidad de borrar ficheros antiguos fruto de la acumulación de copias de seguridad con distinto nombre y de distintas fechas, saturando el servidor de copias de seguridad.

La carpeta por defecto donde guarda los parámetros y la subcarpeta de log es CSIDL_LOCAL_APPDATA, que normalmente es C:\Users\NombreUsuario\AppData\Local\BorrarFich\ donde NombreUsuario es el nombre de su usuario de Windows.

En esta carpeta, con la primera ejecución del ejecutable está config.ini, cuyo contenido por defecto es: 

[Settings]
Folders=
Days=0
Months=0
Years=0
MinFiles=0

En la linea Folders se pondrán todas las carpetas que se quieran procesar, sus rutas completas separadas por ";", la última carpeta no es necesario poner el punto y coma pero si se pone, no da problemas. Si por ejemplo, en Folders hubiera alguna carpeta, como "Folders=C:\PRUEBA;C:\PRUEBA2" Las carpetas C:\PRUEBA Y C:\PRUEBA2 se verán afectadas por el proceso de borrado.
Days es el número de días de antigüedad,
Months es el número de meses de antigüedad,
Years es el número de años de antigüedad, 
Las tres cifras (Days, Months, Years) son números enteros, y se suman, es decir que si hay 1 Years y 2 Months, se sumarán, y se procesarán todos los ficheros cuya antigüedad mínima sea de dos meses y y un año a partir de la fecha actual del sistema.
Todos los ficheros que contengan las carpetas Folders se comparará la fecha obtenida del sistema menos los dias, meses y años, con su la fecha de última modificación.
MinFiles es el número mínimo de ficheros a conservar, se cuentan sólo los que cumplan la antigüedad. Es decir si pongo MinFiles=10 y hay 20 ficheros que cumplen la antigüedad, se dejarán sin borrar los 10 más modernos, y se borrarán los 10 más antiguos.

Cuando hay parámetros por linea de comando, estos tienen prioridad sobre los parámetros en fichero ini.
Los parámetros por linea de comando no tienen por qué estar en orden, no se requiere que esté uno antes de otro.
Los parámetros por linea de comando pueden estar en mayúsculas o minúsculas o en una combinación de ambas.
n el posible caso de que hubiera Days, Months o Years en el ini y también usara parámetros por linea de comando, aunque los parámetros por linea de comando tienen preferencia, OJO!!! si algún parámetro estuviera en el ini pero no estuviera en linea de parámetros, se sumaría a los que estuvieran en linea de comandos.
Los posibles parámetros son:

PARÁMETRO          EXPLICACIÓN
_____________________________________________
/simulate          No borra los ficheros si no que muestra la información en el log de los que borraría.
/verboselog        Hace que el log aparte de escribirse en un fichero, se muestre también por pantalla.
/Folders CARPETA   Sustituye al parámetro de igual nombre del ini visto con anterioridad; la carpeta o carpetas siguen el mismo formato, separadas entre sí por ";" si hubiera varias.
/Days N            Sustituye al parámetro de igual nombre del ini.
/Months N          Sustituye al parámetro de igual nombre del ini.
/Years N           Sustituye al parámetro de igual nombre del ini.
/MinFiles N        Sustituye al parámetro de igual nombre del ini.

Ejemplo de LOG
2025-04-02 18:18:50.289 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: La fecha mínima a conservar es: 02/04/2024 18:18:50 - INFO
2025-04-02 18:18:50.289 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Las fechas más antiguas serán eliminadas - INFO
2025-04-02 18:18:50.290 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: El número mínimo de ficheros antiguos a conservar es de 10 - INFO
2025-04-02 18:18:50.297 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Carpeta: c:\prueba - INFO
2025-04-02 18:18:50.297 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Hay 14 ficheros que cumplen la fecha mínima para borrar. - INFO
2025-04-02 18:18:50.300 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Hay 4 ficheros candidatos efectivos para borrar. - INFO
2025-04-02 18:18:50.301 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] WARNING: c:\pruebaIDETheme.ActnCtrls.pas se borrará Fecha Modificación: 17/04/2023 20:03:15 - WARNING
2025-04-02 18:18:50.302 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] WARNING: c:\pruebainLibNet.pas se borrará Fecha Modificación: 05/11/2023 16:23:30 - WARNING
2025-04-02 18:18:50.303 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] WARNING: c:\pruebainLibScriptDB.pas se borrará Fecha Modificación: 15/11/2023 20:46:46 - WARNING
2025-04-02 18:18:50.304 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] WARNING: c:\pruebaUniDataPerfiles.dfm se borrará Fecha Modificación: 16/11/2023 19:59:28 - WARNING
2025-04-02 18:18:50.305 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Se ha borrado c:\prueba\IDETheme.ActnCtrls.pas - INFO
2025-04-02 18:18:50.306 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Se ha borrado c:\prueba\inLibNet.pas - INFO
2025-04-02 18:18:50.307 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Se ha borrado c:\prueba\inLibScriptDB.pas - INFO
2025-04-02 18:18:50.308 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] INFO: Se ha borrado c:\prueba\UniDataPerfiles.dfm - INFO
2025-04-02 18:18:50.309 - [Instance: {B337F8CC-B3D0-45FA-8931-AC6E1BE1E2E2}] Logging session ended. - INFO
