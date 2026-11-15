<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US"/>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Mi Billetera Digital</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <span class="navbar-brand fw-semibold">Mi Billetera Digital</span>
        <span class="badge text-bg-secondary">JSP + Servlet</span>
    </div>
</nav>

<main class="container py-4">

    <%-- Mensajes --%>
    <c:if test="${not empty error}">
        <div class="alert alert-danger" role="alert">${error}</div>
    </c:if>
    <c:if test="${not empty sessionScope.exito}">
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            ${sessionScope.exito}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Cerrar"></button>
        </div>
        <c:remove var="exito" scope="session"/>
    </c:if>

    <div class="row g-4">
        <%-- Saldo --%>
        <div class="col-md-5">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h6 class="text-uppercase text-muted small">Saldo disponible</h6>
                    <p class="display-5 fw-bold text-success mb-1">
                        S/ <fmt:formatNumber value="${sessionScope.saldo}" pattern="#,##0.00"/>
                    </p>
                    <small class="text-muted">
                        Después de ${sessionScope.movimientos.size()} movimiento(s) válido(s)
                    </small>
                </div>
            </div>
        </div>

        <%-- Nuevo movimiento --%>
        <div class="col-md-7">
            <div class="card shadow-sm h-100">
                <div class="card-body">
                    <h5 class="card-title">Nuevo movimiento</h5>
                    <form method="post" action="${pageContext.request.contextPath}/billetera" class="row g-3">
                        <div class="col-sm-5">
                            <label for="tipo" class="form-label">Tipo</label>
                            <select id="tipo" name="tipo" class="form-select">
                                <option value="Recarga" ${tipoIngresado == 'Gasto' ? '' : 'selected'}>Recarga</option>
                                <option value="Gasto" ${tipoIngresado == 'Gasto' ? 'selected' : ''}>Gasto</option>
                            </select>
                        </div>
                        <div class="col-sm-7">
                            <label for="monto" class="form-label">Monto (S/)</label>
                            <input type="text" id="monto" name="monto" class="form-control ${not empty error ? 'is-invalid' : ''}"
                                   placeholder="0.00" inputmode="decimal" value="<c:out value='${montoIngresado}'/>">
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary w-100">Registrar movimiento</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <%-- Historial --%>
    <div class="card shadow-sm mt-4">
        <div class="card-body">
            <h5 class="card-title">Movimientos recientes</h5>
            <c:choose>
                <c:when test="${empty sessionScope.movimientos}">
                    <p class="text-muted mb-0">Aún no hay movimientos.</p>
                </c:when>
                <c:otherwise>
                    <div class="table-responsive">
                        <table class="table align-middle mb-0">
                            <thead class="table-dark">
                            <tr>
                                <th>Tipo</th>
                                <th class="text-end">Monto (S/)</th>
                                <th class="text-end">Orden</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="m" items="${sessionScope.movimientos}" varStatus="st">
                                <tr>
                                    <td>
                                        <span class="badge rounded-pill ${m.recarga ? 'text-bg-success' : 'text-bg-danger'} px-3">${m.tipo}</span>
                                    </td>
                                    <td class="text-end fw-semibold ${m.recarga ? 'text-success' : 'text-danger'}">
                                        ${m.recarga ? '+' : '-'} <fmt:formatNumber value="${m.monto}" pattern="#,##0.00"/>
                                    </td>
                                    <td class="text-end text-muted small">${st.first ? 'Más reciente' : 'Anterior'}</td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
