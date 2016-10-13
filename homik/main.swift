//
//  main.swift
//  homik
//
//  Created by kyb on 09/10/2016.
//  Copyright © 2016 Suborbital Softowrks Ltd. All rights reserved.
//

import Foundation
import Darwin.ncurses


var homik = Homik()

func initcurses() {
    initscr()
    cbreak()
    noecho()
    raw()
    nonl()
    intrflush(stdscr, true)     // Prevent flush
    keypad(stdscr, true)        // Enable function and arrow keys
    curs_set(0)                 // Set cursor to invisible
    start_color()
    
    init_pair(1, Int16(COLOR_BLACK), Int16(COLOR_GREEN))
    init_pair(2, Int16(COLOR_YELLOW), Int16(COLOR_RED))
}

func drawscreen() {
    let message = "Gonna get raped"
    
    let screen = (width: getmaxx(stdscr), height: getmaxy(stdscr))
    
    
    let xpos: Int32 = screen.width / 2 - Int32(message.characters.count / 2)
    let ypos: Int32 = screen.height / 2
    
    move(ypos, xpos)
    
    attron(COLOR_PAIR(1))
    addstr(message)
    attroff(COLOR_PAIR(1))
    //    refresh()
}

func drawwindow(label: String, x: Int32, y: Int32, width: Int32, height: Int32) {
    let w = newwin(height, width, y, x)
    box(w, 0, 0)
    
    let xpos = width / 2 - Int32(label.characters.count / 2)
    let ypos = height / 2
    
    wmove(w, ypos, xpos)
    waddstr(w, label)
    
    wrefresh(w)
    
    delwin(w)
}

func drawReport(report: StatusReport, x: Int32, y: Int32) {
    let width: Int32 = 30
    let height: Int32 = 10
    
    let w = newwin(height, width, y, x)
    
    
    let label = report.service.endpoint
    
    let xpos = Int32(2)
    var ypos = Int32(2)
    
    wmove(w, ypos, xpos)
    waddstr(w, "\(report.service.type)")

    ypos += 1
    wmove(w, ypos, xpos)
    waddstr(w, label)

    ypos += 1
    wmove(w, ypos, xpos)
    waddstr(w, "Status: \(report.status)")
    
    switch report.status {
    case .OK:
        wbkgd(w, UInt32(COLOR_PAIR(1)))
    default:
        wbkgd(w, UInt32(COLOR_PAIR(2)))
    }

    box(w, 0, 0)
    
    wrefresh(w)

    delwin(w)
}

func drawTimestamp() {
    let w = getmaxx(stdscr)
    let ts = Date().timeIntervalSince1970
    let label = "UNIX: \(Int(ts))"
    
    let xpos: Int32 = w / 2 - 30 / 2
    let ypos: Int32 = 1
    
    drawwindow(label: label,
               x: xpos,
               y: ypos,
               width: 30,
               height: 3)
}

func coordsForIndex(index: Int) -> (x: Int32, y: Int32) {
    return (x: Int32(index * 34 + 6), y: 4)
    
}

func mainloop() {
//    nodelay(stdscr, true)
    timeout(1000/2)
    refresh()

    while true {
        
        let reps = homik.reports
        
        for (idx, rep) in reps.enumerated() {
            let coords = coordsForIndex(index: idx)
            drawReport(report: rep, x: coords.x, y: coords.y)
        }

        drawTimestamp()
        homik.update()

        //we should block until we have some event that requires refresh (key press, mouse click, timer forced refresh, etc)
        //probably write a signal handler or use libev directly
        switch getch() {
            
        case Int32(UnicodeScalar("q").value):
            endwin()
            exit(EX_OK)
        default:
            continue
        }
        

    }
}


func main() {
    homik.monitorWebsite(url: "http://fettemama.org")
    homik.monitorWebsite(url: "https://suborbital.io")
    homik.monitorWebsite(url: "https://www.fluxforge.com")
    
    initcurses()
    mainloop()
}

main()

