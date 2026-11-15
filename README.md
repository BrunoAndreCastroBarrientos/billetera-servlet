# Billetera Digital: Recarga y Movimientos (Caso 1, Servlet + JSP)

T1 del curso **Soluciones Web y Aplicaciones Distribuidas**, UPN.

Es una aplicación web en Java puro, sin frameworks. Un Servlet controlador recibe las peticiones y hace `forward()` a una vista JSP, que muestra los datos con JSTL y Bootstrap. El saldo y el historial se guardan en la `HttpSession`.

## Integrantes
| Nombre | Código |
|---|---|
| Bruno Andre Castro Barrientos | N00375795 |
| Joseth Valdez Lopez | N00374266 |

## Versiones utilizadas
| Herramienta | Versión |
|---|---|
| Java (JDK) | 21 |
| Apache Maven | 3.9.x |
| Apache Tomcat | 10.1.x (Jakarta EE 10) |
| Jakarta Servlet API | 6.0.0 |
| Jakarta JSTL | 3.0 (API 3.0.0, implementación GlassFish 3.0.1) |
| Bootstrap | 5.3.8 (CDN) |

## Estructura
```
src/main/java/pe/edu/upn/billetera/
├── model/Movimiento.java            # Tipo (Recarga/Gasto) y monto
└── servlet/BilleteraServlet.java    # GET muestra, POST valida y registra
src/main/webapp/
├── index.jsp                        # Redirige a /billetera
└── WEB-INF/
    ├── web.xml
    └── views/billetera.jsp          # Vista con JSTL (<c:forEach>), sin scriptlets
```

## Funcionamiento
- **GET `/billetera`**: si la sesión es nueva, la inicia con un saldo de S/ 250.00 y el historial vacío, y luego muestra la vista.
- **POST `/billetera`**: valida el tipo y el monto.
  - Rechaza los montos vacíos, no numéricos, iguales a cero o negativos, y los gastos mayores al saldo. El mensaje de error aparece en la misma vista y los datos no cambian.
  - Si el movimiento es válido, actualiza el saldo, agrega el movimiento **al inicio** del historial y aplica **Post-Redirect-Get** (`sendRedirect`) para que al recargar la página no se reenvíe el formulario.

## Ejecución

### 1. Generar el .war
```bash
mvn clean package
```
El archivo queda en `target/billetera.war`.

### 2. Desplegar en Tomcat 10.1
1. Copiar `target/billetera.war` a la carpeta `webapps/` de Tomcat.
2. Iniciar Tomcat:
   - Windows: `bin\startup.bat`
   - Linux/macOS: `bin/startup.sh`
3. Abrir http://localhost:8080/billetera/

> El proyecto usa `jakarta.*`, así que necesita **Tomcat 10 o superior**. No funciona en Tomcat 9.

### Desde un IDE
Se puede abrir como proyecto Maven en NetBeans, IntelliJ o Eclipse y ejecutarlo con un servidor Tomcat 10.1 configurado.

## Pruebas funcionales
| # | Acción | Resultado |
|---|---|---|
| 1 | Abrir la aplicación | Saldo S/ 250.00 e historial vacío |
| 2 | Recarga de S/ 100.00 | Saldo S/ 350.00 |
| 3 | Gasto de S/ 50.00 | Saldo S/ 300.00; el gasto aparece antes que la recarga |
| 4 | Gasto de S/ 400.00 | "Saldo insuficiente"; el saldo sigue en S/ 300.00 |
| 5 | Monto 0, negativo, vacío o texto | Se rechaza; no cambia el saldo ni el historial |
