//
//  TodoCharts.swift
//  TaskFlow
//
//  Created by Данил Забинский on 17.03.2025.
//

import SwiftUI
import Charts

struct TodoCharts: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var statisticViewModel: StatisticViewModel // subscribe to VM @PublishedFields changing
    @State private var isChartVisible = false
    @State private var averagePerTimeIntervar: Int = 0
    
    @State private var rawSelectedChartData: Date?
    var selectedChartData: ChartDataPoint? {
        guard let rawSelectedChartData else { return nil }
        let currentGranularity: Calendar.Component =
        (statisticViewModel.selectedTimeRange == .day ) ? .day     :
        (statisticViewModel.selectedTimeRange == .week) ? .weekday : .dayOfYear
        
        return statisticViewModel.chartData.first {
            Calendar.current.isDate($0.date, equalTo: rawSelectedChartData, toGranularity: currentGranularity)
        }
    }
    
    private var maxValue: Int { statisticViewModel.chartData.map(\.count).max() ?? 0 }
    private var barmarkWidth: CGFloat { statisticViewModel.getBarMarkHeight() }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Statistics")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            Picker("Periods", selection: $statisticViewModel.selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { timeRange in
                    Text(timeRange.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            chartsView
        }
        .padding(.vertical)
        .onAppear {
            statisticViewModel.updateChartData()
            
            withAnimation {
                isChartVisible = true
            }
        }
        .onChange(of: statisticViewModel.selectedTimeRange) { _, newValue in
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0)) {
                statisticViewModel.updateChartData(for: newValue)
                averagePerTimeIntervar = statisticViewModel.getAverage()
            }
        }
    }
    
    private var chartsView: some View {
        Chart {
            
            if let selectedChartData {
                RuleMark(x: .value("Selected day", selectedChartData.date, unit: .day))
                    .foregroundStyle(.secondary)
                    .opacity(0.3)
                    .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart),
                                                                          y: .disabled)) {
                        VStack(alignment: .leading) {
                            Text("Finished:")
                                .font(.title3)
                                .foregroundStyle(.gray)
                            
                            Text("\(selectedChartData.count)")
                                .bold()
                                .font(.title2)
                                .foregroundStyle(.background)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(SelectedColor.backgroundColor).gradient)
                                .frame(width: 100, height: 65)
                                .padding()
                        )
                    }
            }
            
            ForEach(statisticViewModel.chartData) { chartData in
                BarMark(
                    x: .value("Date", chartData.date, unit: .day),
                    y: .value("Value", chartData.count),
                    width: .fixed(barmarkWidth)
                )
                .cornerRadius(5)
                .opacity(rawSelectedChartData == nil || chartData.date == selectedChartData?.date ? 1 : 0.5)
                .foregroundStyle(Color(SelectedColor.backgroundColor).gradient)
                .annotation(position: .top) {
                    if chartData.count != 0 {
                        
                        Text("\(chartData.count)")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(4)
                            .opacity(selectedChartData == nil ? 1 : 0)
                            .animation(.easeInOut)
                    }
                }
            }
            
            RuleMark(y: .value("Average", averagePerTimeIntervar))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                .foregroundStyle(Color.mint)
                .opacity(statisticViewModel.selectedTimeRange == .day ? 0 : (rawSelectedChartData == nil ? 1 : 0))
                .annotation(position: .top, alignment: .trailing, spacing: 5) {
                    Text("Average per \(statisticViewModel.selectedTimeRange.rawValue): \(averagePerTimeIntervar)")
                        .font(.caption)
                        .foregroundColor(.mint)
                        .opacity(statisticViewModel.selectedTimeRange == .day ? 0 : (rawSelectedChartData == nil ? 1 : 0))
                }
        }
        .chartXSelection(value: $rawSelectedChartData.animation(.easeInOut))
        .frame(height: UIScreen.main.bounds.height / 4)
        .padding()
        .padding(.vertical, 8)
        .background(backgroundRectangleView)
        .padding(.horizontal, 8)
        .scaleEffect(isChartVisible ? 1 : 0.5)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isChartVisible)
        .chartXAxis {
            if statisticViewModel.selectedTimeRange == .week {
                AxisMarks(position: .bottom, values: statisticViewModel.chartData.map { $0.date }) { date in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            } else if statisticViewModel.selectedTimeRange == .month {
                AxisMarks()
            }
        }
    }
    
    private var backgroundRectangleView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: colorScheme == .dark ? .white.opacity(0.15)
                                                : .black.opacity(0.15),
                    radius: 10,
                    x: 0,
                    y: 5)
    }
}

#Preview {
    TodoCharts(statisticViewModel: StatisticViewModel(todoService: TodoService(), onTodoRestoringCompletion: { _, _ in }))
}

