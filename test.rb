require "google_drive"
session = GoogleDrive::Session.from_config("config.json")
ws = session.spreadsheet_by_key("1hOkZeFZMyD32NRLrs8AgZQEZnWulTnugYJw0gp2jxUs").worksheets[0]
drugaTabela = session.spreadsheet_by_key("1QRpEwJfgQaNRP8vhPNfmjgXGExxOSI2Oe7u8a-cWhvs").worksheets[0]

class GoogleSheet
  include Enumerable
  attr_accessor :redovi

  def initialize(ws)
    @ws = ws
    @redovi = @ws.rows
    @redovi= @redovi.select{|i| !i.include? "total" and !i.include? "subtotal"}
    @kolone=[]
    @redovi.transpose.each do |n|
      s= Kolona.new(n[0],n,n[1..])
      @kolone.push(s)
    end
    @tabelaTransponovana = @ws.rows.transpose
  end

  def returnTabela
    return @tabelaTransponovana
  end

  def row(a)
    return @redovi[a]
  end

  def each
    yield @redovi
  end

  def [] (a)
    @kolone.each do |n|
      if(n.ime== a)
        return n.vrednosti
      end
    end
  end

  def + (obj)
    flag=false
    @redovi[0].each do |n|
      if(n!= obj[n][0])
        return "Zaglavlja nisu jednaka"
      end
    end
    obj.redovi.shift()
    return @redovi+obj.redovi
  end

  def - (obj)
    flag=false
    @redovi[0].each do |n|
      if(n!= obj[n][0])
        return "Zaglavlja nisu jednaka"
      end
    end
    obj.redovi.shift()
    return @redovi-obj.redovi
  end

  def method_missing(key, *args)
    izabranaKolona = @kolone.select{|i| i.ime==key.to_s}
    return izabranaKolona[0]
  end

end


class Kolona
  include Enumerable
  attr_accessor :vrednostiKolone, :vrednosti,:ime

  def initialize(ime,vrednosti,vrednostiKolone)
    @ime = ime
    @vrednosti = vrednosti
    @vrednostiKolone=vrednostiKolone
  end

  def prvaKolona
    @kolone.each do |n|
      if(n.ime== "Prva Kolona")
        return n
      end
    end
  end

  def drugaKolona
    @kolone.each do |n|
      if(n.ime== "Druga Kolona")
        return n
      end
    end
  end

  def trecaKolona
    @kolone.each do |n|
      if(n.ime== "Treca Kolona")
        return n
      end
    end
  end

  def sum
    sum=0
    @vrednostiKolone.each do |n|
      sum+= n.to_i()
    end
    return sum
  end

  def avg
    sum=0
    brojCinilaca = 0.0
    @vrednostiKolone.each do |n|
      number = n.to_i()
      if(number.to_s()==n)
        sum+= number
        brojCinilaca+=1
      end
    end

    return sum/brojCinilaca
  end


  def each
    yield @vrednostiKolone
  end

end

t = GoogleSheet.new(ws)
s = GoogleSheet.new(drugaTabela)

#1. (0.5 Poena) Biblioteka može da vrati dvodimenzioni niz sa vrednostima tabele

#p t.returnTabela

#2. (0.5 Poena) Moguće je pristupati redu preko t.row(1), i pristup njegovim elementima po sintaksi niza.

#p t.row(2)

#3. (0.5 Poena) Mora biti implementiran Enumerable modul(each funkcija), gde se vraćaju sve ćelije unutar tabele, sa leva na desno

#t.each {|redovi|
#     redovi.each do |n|
#        n.each do |s|
#           p s
#        end
#end}

#5 (1.0 Poena) [ ] sintaksa mora da bude obogaćena tako da je moguće pristupati određenim vrednostima.
#Biblioteka vraća celu kolonu kada se napravi upit t[“Prva Kolona”]
#Biblioteka omogućava pristup vrednostima unutar kolone po sledećoj sintaksi t[“Prva Kolona”][1] za pristup drugom elementu te kolone
#Biblioteka omogućava podešavanje vrednosti unutar ćelije po sintaksi
#p t["Druga Kolona"][2]
#t["Druga Kolona"][2]= "2556"
#p t["Druga Kolona"]


#t.returnCells


#6. (5.0 Poena) Biblioteka omogućava direktni pristup kolonama, preko istoimenih metoda.
#t.prvaKolona, t.drugaKolona, t.trecaKolona
#Subtotal/Average  neke kolone se može sračunati preko sledećih sintaksi t.prvaKolona.sum i t.prvaKolona.avg

#p t.prvaKolona.sum
#p t.prvaKolona.avg

#8(0.5 Poena) Moguce je sabiranje dve tabele, sve dok su im headeri isti. Npr t1+t2, gde svaka predstavlja, tabelu unutar jednog od worksheet-ova. Rezultat će vratiti novu tabelu gde su redovi(bez headera) t2 dodati unutar t1. (SQL UNION operacija)
#t= t+s
#p t
#
#9(0.5 Poena) Moguce je oduzimanje dve tabele, sve dok su im headeri isti. Npr t1-t2, gde svaka predstavlja reprezentaciju jednog od worksheet-ova. Rezultat će vratiti novu tabelu gde su svi redovi iz t2 uklonjeni iz t1, ukoliko su identicni.
#t=t-s
#p t