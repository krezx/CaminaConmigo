//
//  AyudaView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

/// Vista que presenta información sobre los centros de ayuda disponibles para las víctimas de violencia de género,
/// incluyendo números de contacto y detalles de centros especializados.
struct AyudaView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Barra superior con el título "Centros de Ayuda"
            VStack {
                Text("Centros de Ayuda")  // Título principal
                    .font(.title)
                    .bold()
                    .padding(.vertical, 5)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)  // Fondo blanco para la barra superior.
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)  // Sombra sutil para la barra.

            Spacer(minLength: 16)  // Espaciado entre la barra superior y el contenido principal.

            // Despliegue de la información en un ScrollView para permitir desplazamiento vertical.
            ScrollView {
                VStack(alignment: .leading) {
                    // Información del programa de atención a víctimas de violencia de género.
                    Text("Programa para víctimas de violencia de género grave o extrema:")
                        .font(.headline)  // Texto destacado para el título.
                        .padding(.bottom, 5)
                    
                    Text("Atención integral, psicosocial, jurídica, psiquiátrica y recuperación de las autonomías económicas para las mujeres. Esta será profunda y especializada, buscando disminuir de alguna manera las violencias de género que siguen sucediendo en el país.")
                        .padding(.bottom, 10)
                    
                    Text("Operará desde fines de mayo la etapa piloto, será un beneficio directo para quienes consulten de manera espontánea y también para usuarias derivadas de Tribunales o Fiscalía.")
                        .padding(.bottom, 15)

                    // Sección de números de contacto para denuncias.
                    Text("Fonos Denuncia:")
                        .font(.headline)  // Título para la sección de números.
                        .padding(.bottom, 5)

                    // Lista de números de contacto para diversas instituciones.
                    HStack {
                        Text("Fono de orientación para la violencia contra la mujer: 1455")
                    }
                    .padding(.bottom, 5)

                    HStack {
                        Text("Fono familia de Carabineros: 149")
                    }
                    .padding(.bottom, 5)

                    HStack {
                        Text("PDI: 134")
                    }
                    .padding(.bottom, 5)

                    HStack {
                        Text("Denuncia Seguro de PDI (pueden ser denuncias como testigo, de carácter anónimo): *4242")
                    }
                    .padding(.bottom, 5)

                    // Sección de Centros de la Mujer con información sobre centros específicos.
                    Text("Centros de la Mujer:")
                        .font(.headline)  // Título para la sección de centros.
                        .padding(.bottom, 5)

                    // Información sobre un centro específico, "Sernameg - La Serena"
                    HStack {
                        Text("Centro de la Mujer Sernameg - La Serena")
                    }
                    .padding(.bottom, 5)

                    // Otro centro de la mujer.
                    HStack {
                        Text("Centro de la Mujer Liwen")
                    }
                    .padding(.bottom, 5)

                    // Horario de atención.
                    HStack {
                        Text("Horario: 8:30 a 17:30 horas.")
                    }
                    .padding(.bottom, 5)

                    // Información de contacto para el centro Liwen.
                    HStack {
                        Text("Contacto: 51-2641850 / 51-2427844 / 961244738")
                    }
                    .padding(.bottom, 5)

                    // Correo electrónico del centro Liwen.
                    HStack {
                        Text("Correo: centroliwen@laserena.cl")
                    }
                    .padding(.bottom, 5)
                }
                .padding()  // Espaciado general dentro del ScrollView.
            }
        }
    }
}

/// Vista previa para previsualizar la vista de ayuda en el canvas de Xcode.
struct AyudaView_Previews: PreviewProvider {
    static var previews: some View {
        AyudaView()  // Previsualización de la vista de ayuda.
    }
}
