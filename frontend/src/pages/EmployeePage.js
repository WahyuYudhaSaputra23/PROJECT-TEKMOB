import React, { useEffect, useState } from 'react';
import axios from 'axios';
import EmployeeTable from '../components/EmployeeTable';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { FaDownload } from 'react-icons/fa';
import * as XLSX from 'xlsx';
import { saveAs } from 'file-saver';
import './EmployeePage.css';

const EmployeePage = () => {
  const [employees, setEmployees] = useState([]);
  const [startDate, setStartDate] = useState(new Date());
  const [endDate, setEndDate] = useState(new Date());
  const [userDurations, setUserDurations] = useState([]);

  useEffect(() => {
    fetchEmployees(startDate, endDate);
  }, [startDate, endDate]);

  const fetchEmployees = async (start, end) => {
    try {
      const response = await axios.get('http://localhost:5000/api/attendance', {
        params: {
          startDate: start.toISOString().substring(0, 10),
          endDate: end.toISOString().substring(0, 10)
        }
      });
      console.log('Fetched employees:', response.data.attendances);
      console.log('Fetched user durations:', response.data.userDurations);
      setEmployees(response.data.attendances);
      setUserDurations(response.data.userDurations);
    } catch (error) {
      console.error('Error fetching employees:', error);
    }
  };

  const autoFitColumns = (worksheet, data) => {
    const objectMaxLength = [];
    for (const row of data) {
      Object.keys(row).forEach((key, i) => {
        const len = row[key] ? row[key].toString().length : 10;
        objectMaxLength[i] = Math.max(objectMaxLength[i] || 0, len);
      });
    }
    worksheet['!cols'] = objectMaxLength.map((width) => ({ width: width + 2 }));
  };

  const downloadExcel = () => {
    const headers = [
      'User ID', 'Full Name', 'User Role', 'Jobdesk', 'Date', 'Branch',
      'Check In', 'Check Out', 'Notes', 'Shift IDs', 'Work Duration'
    ];

    const data = employees.map(employee => ({
      'User ID': employee.userID ? employee.userID._id : 'N/A',
      'Full Name': employee.userID ? employee.userID.fullName : 'N/A',
      'User Role': employee.userRole,
      Jobdesk: employee.jobdesk,
      Date: new Date(employee.date).toLocaleDateString(),
      Branch: employee.branch ? employee.branch.name : 'N/A',
      'Check In': employee.checkIn ? new Date(employee.checkIn).toLocaleTimeString() : 'N/A',
      'Check Out': employee.checkOut ? new Date(employee.checkOut).toLocaleTimeString() : 'N/A',
      Notes: employee.notes,
      'Shift IDs': employee.shiftIDs.map(shiftID => `${shiftID.shiftName}`).join(', '),
      'Work Duration': employee.workDuration,
    }));

    const userDurationHeaders = ['User ID', 'Full Name', 'Total Work Duration'];
    const userDurationData = userDurations.map(user => ({
      'User ID': user.userId,
      'Full Name': user.fullName,
      'Total Work Duration': user.totalWorkDuration,
    }));

    const employeeWorksheet = XLSX.utils.json_to_sheet(data, { header: headers });
    const userDurationWorksheet = XLSX.utils.json_to_sheet(userDurationData, { header: userDurationHeaders });

    autoFitColumns(employeeWorksheet, data);
    autoFitColumns(userDurationWorksheet, userDurationData);

    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, employeeWorksheet, 'Employees');
    XLSX.utils.book_append_sheet(workbook, userDurationWorksheet, 'Total Work Durations');

    const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
    const blobData = new Blob([excelBuffer], { type: 'application/octet-stream' });

    saveAs(blobData, `employees_${startDate.toISOString().substring(0, 10)}_${endDate.toISOString().substring(0, 10)}.xlsx`);
  };

  return (
    <div className="page">
      <div className="page-header">
        <h1>Employees</h1>
        <div className="controls">
          <DatePicker
            selected={startDate}
            onChange={(date) => setStartDate(date)}
            dateFormat="yyyy-MM-dd"
            className="date-picker"
          />
          <DatePicker
            selected={endDate}
            onChange={(date) => setEndDate(date)}
            dateFormat="yyyy-MM-dd"
            className="date-picker"
          />
          <button className="btn-download" onClick={downloadExcel}>
            <FaDownload /> Download
          </button>
        </div>
      </div>
      <EmployeeTable employees={employees} />
      <div className="user-durations">
        <h2>Total Work Duration per User</h2>
        <table>
          <thead>
            <tr>
              <th>User ID</th>
              <th>Full Name</th>
              <th>Total Work Duration</th>
            </tr>
          </thead>
          <tbody>
            {userDurations.map(user => (
              <tr key={user.userId}>
                <td>{user.userId}</td>
                <td>{user.fullName}</td>
                <td>{user.totalWorkDuration}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default EmployeePage;
