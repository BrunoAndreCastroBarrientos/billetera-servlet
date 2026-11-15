package pe.edu.upn.billetera.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import pe.edu.upn.billetera.model.Movimiento;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;

/**
 * Controlador de la billetera.
 * GET  -> muestra saldo e historial.
 * POST -> valida y registra un nuevo movimiento.
 */
@WebServlet("/billetera")
public class BilleteraServlet extends HttpServlet {

    private static final BigDecimal SALDO_INICIAL = new BigDecimal("250.00");
    private static final String VISTA = "/WEB-INF/views/billetera.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        inicializarSesion(req.getSession());
        req.getRequestDispatcher(VISTA).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession();
        inicializarSesion(session);

        String tipo = req.getParameter("tipo");
        String montoTexto = req.getParameter("monto");
        BigDecimal saldo = (BigDecimal) session.getAttribute("saldo");

        String error = null;
        BigDecimal monto = null;

        if (!Movimiento.RECARGA.equals(tipo) && !Movimiento.GASTO.equals(tipo)) {
            error = "Selecciona un tipo de movimiento válido.";
        } else if (montoTexto == null || montoTexto.isBlank()) {
            error = "El monto es obligatorio.";
        } else {
            try {
                monto = new BigDecimal(montoTexto.trim()).setScale(2, RoundingMode.HALF_UP);
                if (monto.compareTo(BigDecimal.ZERO) <= 0) {
                    error = "El monto debe ser mayor que cero.";
                } else if (Movimiento.GASTO.equals(tipo) && monto.compareTo(saldo) > 0) {
                    error = "Saldo insuficiente. Gasto solicitado: S/ " + monto
                            + " - Saldo disponible: S/ " + saldo;
                }
            } catch (NumberFormatException e) {
                error = "El monto debe ser un número válido.";
            }
        }

        if (error != null) {
            // Movimiento inválido: no se modifica la sesión
            req.setAttribute("error", error);
            req.setAttribute("tipoIngresado", tipo);
            req.setAttribute("montoIngresado", montoTexto);
            req.getRequestDispatcher(VISTA).forward(req, resp);
            return;
        }

        BigDecimal nuevoSaldo = Movimiento.RECARGA.equals(tipo) ? saldo.add(monto) : saldo.subtract(monto);
        session.setAttribute("saldo", nuevoSaldo);
        obtenerMovimientos(session).add(0, new Movimiento(tipo, monto)); // al inicio del historial
        session.setAttribute("exito", "Movimiento registrado: " + tipo + " de S/ " + monto);

        // Post-Redirect-Get: evita reenviar el formulario al actualizar
        resp.sendRedirect(req.getContextPath() + "/billetera");
    }

    private void inicializarSesion(HttpSession session) {
        if (session.getAttribute("saldo") == null) {
            session.setAttribute("saldo", SALDO_INICIAL);
            session.setAttribute("movimientos", new ArrayList<Movimiento>());
        }
    }

    @SuppressWarnings("unchecked")
    private List<Movimiento> obtenerMovimientos(HttpSession session) {
        return (List<Movimiento>) session.getAttribute("movimientos");
    }
}
