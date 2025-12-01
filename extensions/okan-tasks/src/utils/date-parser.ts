/**
 * 期日文字列をパースしてDateオブジェクトを返す
 * 対応形式: YYYY/M/D, YYYY-M-D, M/D
 */
export function parseDeadline(deadline: string, today: Date): Date | null {
  let year: number | null = null;
  let month: number | null = null;
  let day: number | null = null;

  const fullDateMatch = deadline.match(/(\d{4})[\/\-](\d{1,2})[\/\-](\d{1,2})/);
  if (fullDateMatch) {
    year = parseInt(fullDateMatch[1], 10);
    month = parseInt(fullDateMatch[2], 10);
    day = parseInt(fullDateMatch[3], 10);
  } else {
    const shortDateMatch = deadline.match(/(\d{1,2})\/(\d{1,2})/);
    if (shortDateMatch) {
      month = parseInt(shortDateMatch[1], 10);
      day = parseInt(shortDateMatch[2], 10);
      year = today.getFullYear();
      const tempDate = new Date(year, month - 1, day);
      const sixMonthsAgo = new Date(today);
      sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);
      if (tempDate < sixMonthsAgo) {
        year = today.getFullYear() + 1;
      }
    }
  }

  if (year === null || month === null || day === null) {
    return null;
  }

  const deadlineDate = new Date(year, month - 1, day);
  deadlineDate.setHours(0, 0, 0, 0);
  return deadlineDate;
}

/**
 * 期日を MM/DD 形式にフォーマット
 */
export function formatDeadline(date: Date): string {
  const month = date.getMonth() + 1;
  const day = date.getDate();
  return `${String(month).padStart(2, '0')}/${String(day).padStart(2, '0')}`;
}
