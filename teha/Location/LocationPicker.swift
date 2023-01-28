//
//  LocationPicker.swift
//  teha
//
//  Created by Nurullah Keskin on 13.01.23.
//

import SwiftUI
import MapKit
import CoreLocation
import os


/*
 ResultItem displays the single Item in the LocationSearch List
 */
fileprivate struct ResultItem: View {
    let searchResult: MKLocalSearchCompletion
    @ObservedObject var locVM: LocationSearch
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "mappin")
                VStack(alignment: .leading, spacing: 0) {
                    Text(searchResult.title)
                    Text(searchResult.subtitle)
                }
            }
        }
        
    }
}

/*
 LocationPickerSheet displays the Sheet which opens after touching the
 "Add Location" Button
 */
fileprivate struct LocationPickerSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @ObservedObject private var locationSearch = LocationSearch()
    
    @Binding var address: String?
    @Binding var lat: Double?
    @Binding var long: Double?
    
    init(address: Binding<String?>, lat: Binding<Double?>, long: Binding<Double?>) {
        self._address = address
        self._lat = lat
        self._long = long
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if !locationSearch.input.isEmpty{
                        List(locationSearch.searchResults,id: \.self) {res in
                            VStack(alignment: .leading, spacing: 0) {
                                ResultItem(searchResult: res, locVM: locationSearch)
                            }
                            .onTapGesture {
                                locationSearch.address = res.title+" "+res.subtitle
                                locationSearch.getCoordinatesFromAddress(from: locationSearch.address) { coord in
                                    if coord != nil {
                                        lat = coord?.latitude
                                        long = coord?.longitude
                                    }
                                }
                                address = locationSearch.address
                                dismiss()
                            }
                        }
                    }else{
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                        Text("Search for a location")
                            .padding()
                            .foregroundColor(.secondaryLabel)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .navigationTitle("Location")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $locationSearch.input, prompt: "Search for a location")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("cancel").fontWeight(.semibold)
                    }
                    
                }
            }
        }
        .presentationDetents([.medium])
    }
}

/*
 LocationPicker is a Button, which displays the current set Address or (if there is not address set) an "Add Location" Button
 */
struct LocationPicker: View {
    let title: LocalizedStringKey
    let addText: LocalizedStringKey
    let removeText: LocalizedStringKey
    
    
    @Binding var address: String?
    @Binding var lat: Double?
    @Binding var long: Double?
    
    @State private var sheet: Bool = false
    
    
    init(_ title: LocalizedStringKey, addText: LocalizedStringKey, removeText: LocalizedStringKey = "remove",address: Binding<String?>, lat: Binding<Double?>, long: Binding<Double?>) {
        self.title = title
        self.addText = addText
        self.removeText = removeText
        self._address = address
        self._lat = lat
        self._long = long
    }
    
    @ViewBuilder
    private var removeLocationButton: some View {
        VStack() {
            HStack{
                Image(systemName: "mappin.and.ellipse")
                Text(address ?? "-").multilineTextAlignment(.leading)
            }
            Button(role: .destructive) {
                address = ""
            } label: {
                Text(removeText)
            }.frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.all, 0)
    }
    
    var body: some View {
        
        ZStack {
            if address != nil && address! != "" {
                removeLocationButton
            } else {
                ZStack {
                    Button {
                        sheet = true
                    } label: {
                        Label(addText, systemImage: "plus.circle")
                    }
                }
                .sheet(isPresented: $sheet) {
                    LocationPickerSheet(address: $address, lat: $lat, long: $long)
                }
            }
        }
    }
}

struct LocationPicker_Previews: PreviewProvider {
    struct LocationPickerPreview: View {
        @State var address: String?
        @State var lat: Double?
        @State var long: Double?
        
        var body: some View {
            LocationPicker("Location", addText: "Add Location", removeText: "Remove Location",address: $address,lat: $lat,long: $long)
        }
    }
    static var previews: some View {
        
        Form {
            LocationPickerPreview(address:"",lat:0.0,long:0.0)
        }
    }
}
