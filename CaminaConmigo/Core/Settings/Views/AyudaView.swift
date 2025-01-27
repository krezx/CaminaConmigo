//
//  AyudaView.swift
//  CaminaConmigo
//
//  Created by a on 20-01-25.
//

import SwiftUI

struct AyudaView: View {
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Centros de Ayuda")
                    .font(.title)
                    .bold()
                    .padding(.vertical, 5)
            }
            .frame(maxWidth:  .infinity)
            .background(Color.white)
            .shadow(color: Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Spacer(minLength: 16)
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Programa para víctimas de violencia de género grave o extrema:")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text("Atención integral, psicosocial, jurídica, psiquiátrica y recuperación de las autonomías económicas para las mujeres. Esta será profunda y especializada, buscando disminuir de alguna manera las violencias de género que siguen sucediendo en el país.")
                        .padding(.bottom, 10)
                    
                    Text("Operará desde fines de mayo la etapa piloto, será un beneficio directo para quienes consulten de manera espontánea y también para usuarias derivadas de Tribunales o Fiscalía.")
                        .padding(.bottom, 15)

                    Text("Fonos Denuncia:")
                        .font(.headline)
                        .padding(.bottom, 5)

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

                    Text("Centros de la Mujer:")
                        .font(.headline)
                        .padding(.bottom, 5)

                    HStack {
                        Text("Centro de la Mujer Sernameg - La Serena")
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("Centro de la Mujer Liwen")
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("Horario: 8:30 a 17:30 horas.")
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("Contacto: 51-2641850 / 51-2427844 / 961244738")
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("Correo: centroliwen@laserena.cl")
                    }
                    .padding(.bottom, 5)
                }
                .padding()
            }
        }
        
    }
}

struct AyudaView_Previews: PreviewProvider {
    static var previews: some View {
        AyudaView()
    }
}
